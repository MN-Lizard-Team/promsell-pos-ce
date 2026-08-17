// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/migration_safety_service.dart';

import '../helpers/scaling_fixture.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p1_migration_safety_');
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('P1-2: MigrationSafetyService', () {
    late AppDatabase db;
    late MigrationSafetyService service;

    setUp(() async {
      final file = File(p.join(tempDir.path, 'safety_test.db'));
      if (file.existsSync()) file.deleteSync();
      db = AppDatabase.forTesting(NativeDatabase(file));
      service = MigrationSafetyService(db);
    });

    tearDown(() async {
      await service.clearMigrationStatus();
      await db.close();
    });

    test('getSchemaVersion returns current schema version', () async {
      final version = await service.getSchemaVersion();
      expect(version, 32); // current schema version
    });

    test('markMigrationStart writes running status', () async {
      await service.markMigrationStart(fromVersion: 31, toVersion: 32);
      final status = await service.readMigrationStatus();
      expect(status, MigrationStatus.running);
    });

    test('markMigrationSuccess writes succeeded status', () async {
      await service.markMigrationStart(fromVersion: 31, toVersion: 32);
      await service.markMigrationSuccess(fromVersion: 31, toVersion: 32);
      final status = await service.readMigrationStatus();
      expect(status, MigrationStatus.succeeded);
    });

    test('markMigrationFailure writes failed status', () async {
      await service.markMigrationStart(fromVersion: 31, toVersion: 32);
      await service.markMigrationFailure(
        fromVersion: 31,
        toVersion: 32,
        error: 'test error',
      );
      final status = await service.readMigrationStatus();
      expect(status, MigrationStatus.failed);
    });

    test(
      'readMigrationStatus returns idle when no status file exists',
      () async {
        final status = await service.readMigrationStatus();
        expect(status, MigrationStatus.idle);
      },
    );

    test('clearMigrationStatus removes the status file', () async {
      await service.markMigrationStart(fromVersion: 31, toVersion: 32);
      await service.clearMigrationStatus();
      final status = await service.readMigrationStatus();
      expect(status, MigrationStatus.idle);
    });

    test('checkFreeSpace returns a result (platform-dependent)', () async {
      final result = await service.checkFreeSpace();
      // On desktop test, free space may be unknown (-1) but canProceed
      // should still be true (we allow migration when free space is unknown).
      expect(result.canProceed, isTrue);
      print('  Free-space preflight: $result');
    });

    test('migration status survives database close/reopen', () async {
      await service.markMigrationStart(fromVersion: 31, toVersion: 32);
      await db.close();

      // Reopen — status file should still be on disk.
      final file = File(p.join(tempDir.path, 'safety_test.db'));
      db = AppDatabase.forTesting(NativeDatabase(file));
      service = MigrationSafetyService(db);

      final status = await service.readMigrationStatus();
      expect(status, MigrationStatus.running);
    });

    test(
      'interrupted migration (running status) is detectable on next launch',
      () async {
        // Simulate: migration started but app crashed before completion.
        await service.markMigrationStart(fromVersion: 31, toVersion: 32);
        await db.close();

        // Reopen — startup code should detect "running" status.
        final file = File(p.join(tempDir.path, 'safety_test.db'));
        db = AppDatabase.forTesting(NativeDatabase(file));
        service = MigrationSafetyService(db);

        final status = await service.readMigrationStatus();
        expect(status, MigrationStatus.running);

        // Recovery: verify DB is still usable.
        final count = await db
            .customSelect('SELECT COUNT(*) AS c FROM products')
            .getSingle();
        expect(count.read<int>('c'), greaterThanOrEqualTo(0));

        // Clear after recovery.
        await service.clearMigrationStatus();
        expect(await service.readMigrationStatus(), MigrationStatus.idle);
      },
    );
  });

  group('P1-2: migration status integration with AppDatabase', () {
    test('migration from v31→v32 with status tracking', () async {
      final file = File(p.join(tempDir.path, 'status_integration.db'));
      if (file.existsSync()) file.deleteSync();
      var db = AppDatabase.forTesting(NativeDatabase(file));

      // Seed at v32.
      await seedScalingFixture(
        db,
        productCount: 100,
        saleCount: 500,
        saleItemCount: 1500,
        inventoryLogCount: 300,
      );

      // Simulate v31 state.
      await db.customStatement('PRAGMA user_version = 31');
      await db.close();

      // Reopen — migration runs.
      db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customSelect('SELECT COUNT(*) AS c FROM sales').getSingle();

      // Verify schema version is back to 32.
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 32);

      await db.close();
    });
  });
}
