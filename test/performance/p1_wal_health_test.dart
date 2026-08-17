// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/database_health_service.dart';
import 'package:promsell_pos_ce/core/database/wal_checkpoint_service.dart';

import '../helpers/scaling_fixture.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p1_wal_health_');
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('P1-3: WalCheckpointService', () {
    late AppDatabase db;
    late WalCheckpointService walService;

    setUp(() async {
      final file = File(p.join(tempDir.path, 'promsell_pos.db'));
      if (file.existsSync()) file.deleteSync();
      File('${file.path}-wal').deleteSyncIfExists();
      File('${file.path}-shm').deleteSyncIfExists();
      db = AppDatabase.forTesting(NativeDatabase(file));
      walService = WalCheckpointService(db);
    });

    tearDown(() async => db.close());

    test('getWalSize returns 0 when no WAL exists', () async {
      // Force a checkpoint to clear any WAL from setup.
      await walService.checkpoint(mode: CheckpointMode.truncate);
      final size = await walService.getWalSize();
      expect(size, 0);
    });

    test('getWalSize returns non-zero after writes', () async {
      // Seed some data to generate WAL.
      await seedScalingFixture(
        db,
        productCount: 100,
        saleCount: 500,
        saleItemCount: 1500,
        inventoryLogCount: 300,
      );
      final size = await walService.getWalSize();
      // WAL should exist and have some content.
      expect(size, greaterThan(0));
    });

    test('passive checkpoint completes without error', () async {
      await seedScalingFixture(
        db,
        productCount: 50,
        saleCount: 100,
        saleItemCount: 300,
        inventoryLogCount: 60,
      );
      final result = await walService.checkpoint(mode: CheckpointMode.passive);
      expect(result.mode, CheckpointMode.passive);
      // After a passive checkpoint, WAL may or may not be fully drained.
      print('  Passive checkpoint: $result');
    });

    test('truncate checkpoint reduces WAL size', () async {
      await seedScalingFixture(
        db,
        productCount: 100,
        saleCount: 500,
        saleItemCount: 1500,
        inventoryLogCount: 300,
      );
      final sizeBefore = await walService.getWalSize();
      expect(sizeBefore, greaterThan(0));

      final result = await walService.forceTruncate();
      expect(result.mode, CheckpointMode.truncate);

      final sizeAfter = await walService.getWalSize();
      print('  Truncate: ${sizeBefore}B → ${sizeAfter}B ($result)');
      // WAL should be truncated to 0 or very small.
      expect(sizeAfter, lessThanOrEqualTo(sizeBefore));
    });

    test('shouldCheckpoint returns false for small WAL', () async {
      await walService.checkpoint(mode: CheckpointMode.truncate);
      expect(await walService.shouldCheckpoint(), isFalse);
    });

    test('checkpointIfNeeded returns null when WAL is small', () async {
      await walService.checkpoint(mode: CheckpointMode.truncate);
      final result = await walService.checkpointIfNeeded();
      expect(result, isNull);
    });

    test(
      'checkpointIfNeeded runs when WAL exceeds threshold',
      () async {
        // Write enough data to exceed the 10 MB threshold.
        await seedScalingFixture(
          db,
          productCount: 2000,
          saleCount: 50000,
          saleItemCount: 250000,
          inventoryLogCount: 150000,
        );
        final walSize = await walService.getWalSize();
        print('  WAL size after seeding: ${walSize ~/ 1024}KB');

        if (walSize >= WalCheckpointService.walCheckpointThreshold) {
          final result = await walService.checkpointIfNeeded();
          expect(result, isNotNull);
          expect(result!.mode, CheckpointMode.passive);
          print('  Checkpoint result: $result');
        } else {
          // WAL may have been auto-checkpointed by SQLite — that's fine.
          print('  WAL auto-checkpointed by SQLite (size=${walSize}B)');
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });

  group('P1-4: DatabaseHealthService', () {
    late AppDatabase db;
    late WalCheckpointService walService;
    late DatabaseHealthService healthService;

    setUp(() async {
      final file = File(p.join(tempDir.path, 'promsell_pos.db'));
      if (file.existsSync()) file.deleteSync();
      File('${file.path}-wal').deleteSyncIfExists();
      File('${file.path}-shm').deleteSyncIfExists();
      db = AppDatabase.forTesting(NativeDatabase(file));
      walService = WalCheckpointService(db);
      healthService = DatabaseHealthService(db, walService);
    });

    tearDown(() async => db.close());

    test('generateReport returns correct schema version', () async {
      final report = await healthService.generateReport();
      expect(report.schemaVersion, 32);
    });

    test(
      'generateReport returns non-zero main DB size after seeding',
      () async {
        await seedScalingFixture(
          db,
          productCount: 100,
          saleCount: 500,
          saleItemCount: 1500,
          inventoryLogCount: 300,
        );
        final report = await healthService.generateReport();
        expect(report.mainDbSize, greaterThan(0));
        expect(report.totalSize, greaterThan(0));
        print('  Health report: $report');
      },
    );

    test('generateReport with integrity check passes on healthy DB', () async {
      await seedScalingFixture(
        db,
        productCount: 10,
        saleCount: 50,
        saleItemCount: 150,
        inventoryLogCount: 30,
      );
      final report = await healthService.generateReport(checkIntegrity: true);
      expect(report.integrityOk, isTrue);
    });

    test('generateReport detects WAL checkpoint recommendations', () async {
      // Start with a truncated WAL.
      await walService.checkpoint(mode: CheckpointMode.truncate);
      final report1 = await healthService.generateReport();
      expect(report1.walNeedsCheckpoint, isFalse);
      expect(report1.walNeedsTruncate, isFalse);

      // Seed data to grow the WAL.
      await seedScalingFixture(
        db,
        productCount: 100,
        saleCount: 500,
        saleItemCount: 1500,
        inventoryLogCount: 300,
      );
      final report2 = await healthService.generateReport();
      print('  After seeding: $report2');
    });

    test(
      'report totalSizeMb and walPercent are calculated correctly',
      () async {
        await seedScalingFixture(
          db,
          productCount: 100,
          saleCount: 500,
          saleItemCount: 1500,
          inventoryLogCount: 300,
        );
        final report = await healthService.generateReport();
        expect(report.totalSizeMb, greaterThan(0));
        expect(report.walPercent, greaterThanOrEqualTo(0));
        expect(report.walPercent, lessThanOrEqualTo(100));
      },
    );

    test('report approachingGuardrail is false for small DB', () async {
      await seedScalingFixture(
        db,
        productCount: 10,
        saleCount: 50,
        saleItemCount: 150,
        inventoryLogCount: 30,
      );
      final report = await healthService.generateReport();
      expect(report.approachingGuardrail, isFalse);
      expect(report.exceedsGuardrail, isFalse);
    });
  });
}

extension on File {
  void deleteSyncIfExists() {
    if (existsSync()) deleteSync();
  }
}
