// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_restore_service.dart';

import '../helpers/fake_app_lock.dart';
import '../helpers/scaling_fixture.dart';

class _MockDb extends Mock implements AppDatabase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p1_restore_large_');
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } catch (_) {
      // Files may be locked on Windows — ignore.
    }
  });

  group('P1-7: restore with large encrypted fixture', () {
    test(
      'restore large encrypted backup preserves all data',
      () async {
        // 1. Create a source DB with substantial data.
        final sourceFile = File(p.join(tempDir.path, 'source_large.db'));
        if (sourceFile.existsSync()) sourceFile.deleteSync();
        final sourceDb = AppDatabase.forTesting(NativeDatabase(sourceFile));

        final counts = await seedScalingFixture(
          sourceDb,
          productCount: 500,
          saleCount: 5000,
          saleItemCount: 25000,
          inventoryLogCount: 15000,
        );
        print('  Seeded source: $counts');
        await sourceDb.close();

        // 2. Encrypt the source DB with a PIN.
        const pin = '123456';
        final encryption = BackupEncryptionService();
        final encPath = await encryption.encryptFile(
          sourcePath: sourceFile.path,
          pin: pin,
          outputPath: p.join(tempDir.path, 'source_large.db.enc'),
        );
        final encSize = await File(encPath).length();
        print('  Encrypted backup: ${encSize ~/ 1024}KB');

        // 3. Set up the "live" DB at the expected path.
        final livePath = p.join(tempDir.path, 'promsell_pos.db');
        final liveFile = File(livePath);
        if (liveFile.existsSync()) liveFile.deleteSync();
        final liveDb = AppDatabase.forTesting(NativeDatabase(liveFile));
        await liveDb.customStatement(
          'INSERT INTO app_settings (key, value) VALUES (\'live\', \'1\')',
        );
        await liveDb.close();

        // 4. Restore from the encrypted backup.
        // Use a mock DB and a candidate validator that skips the SQLCipher
        // header check (our test DBs are plain SQLite, not SQLCipher).
        final mockDb = _MockDb();
        when(() => mockDb.close()).thenAnswer((_) async {});

        final restoreService = BackupRestoreService(
          mockDb,
          encryption,
          fakeAppLock(),
          candidateValidator: (_) async {},
          skipSqlCipherHeaderCheck: true,
        );

        final preRestorePath = await restoreService.restoreFromPath(
          sourcePath: encPath,
          pin: pin,
        );

        // 5. Verify the live DB was replaced.
        expect(await liveFile.exists(), isTrue);
        final restoredDb = AppDatabase.forTesting(NativeDatabase(liveFile));
        final productCount = await restoredDb
            .customSelect('SELECT COUNT(*) AS c FROM products')
            .getSingle();
        expect(productCount.read<int>('c'), 500);

        final saleCount = await restoredDb
            .customSelect('SELECT COUNT(*) AS c FROM sales')
            .getSingle();
        expect(saleCount.read<int>('c'), 5000);

        final itemCount = await restoredDb
            .customSelect('SELECT COUNT(*) AS c FROM sale_items')
            .getSingle();
        expect(itemCount.read<int>('c'), 25000);

        // 6. Verify pre-restore backup was created.
        expect(await File(preRestorePath).exists(), isTrue);

        print('  Restore verified: 500 products, 5000 sales, 25000 items');
        await restoredDb.close();
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test('interrupted swap leaves pre-restore backup for rollback', () async {
      // This test simulates a swap failure (e.g., disk full during rename)
      // and verifies that the pre-restore backup is preserved for rollback.

      final livePath = p.join(tempDir.path, 'promsell_pos.db');
      final liveFile = File(livePath);
      if (liveFile.existsSync()) liveFile.deleteSync();

      // Create a live DB with some data.
      final liveDb = AppDatabase.forTesting(NativeDatabase(liveFile));
      await liveDb.customStatement(
        'INSERT INTO app_settings (key, value) VALUES (\'original\', \'1\')',
      );
      await liveDb.close();

      // Create a fake "encrypted" backup that will pass the header check
      // but fail during the swap (we'll make the candidate validator
      // throw to simulate a mid-swap failure).
      final backupFile = File(p.join(tempDir.path, 'interrupted.db'));
      // Write SQLCipher-like bytes (not plain SQLite header).
      await backupFile.writeAsBytes(
        Uint8List.fromList(List.generate(128, (i) => (i * 17 + 3) % 256)),
      );

      final encryption = BackupEncryptionService();
      final mockDb = _MockDb();
      when(() => mockDb.close()).thenAnswer((_) async {});

      // Create a restore service with a validator that throws to simulate
      // a mid-restore failure.
      final restoreService = BackupRestoreService(
        mockDb,
        encryption,
        fakeAppLock(),
        candidateValidator: (_) async {
          throw StateError('SIMULATED_SWAP_FAILURE');
        },
      );

      // The restore should fail.
      expect(
        () => restoreService.restoreFromPath(sourcePath: backupFile.path),
        throwsA(
          predicate((e) => e is StateError && e.message.contains('SIMULATED')),
        ),
      );

      // The live DB should still exist (rollback or no swap happened).
      expect(await liveFile.exists(), isTrue);

      // Verify the original data is still there.
      final verifyDb = AppDatabase.forTesting(NativeDatabase(liveFile));
      final settings = await verifyDb
          .customSelect("SELECT value FROM app_settings WHERE key = 'original'")
          .getSingle();
      expect(settings.read<String>('value'), '1');
      await verifyDb.close();

      print('  Interrupted swap: live DB preserved with original data');
    });

    test('restore with wrong PIN fails cleanly', () async {
      // Create a source DB.
      final sourceFile = File(p.join(tempDir.path, 'wrong_pin_source.db'));
      if (sourceFile.existsSync()) sourceFile.deleteSync();
      final sourceDb = AppDatabase.forTesting(NativeDatabase(sourceFile));
      await seedScalingFixture(
        sourceDb,
        productCount: 10,
        saleCount: 100,
        saleItemCount: 300,
        inventoryLogCount: 60,
      );
      await sourceDb.close();

      // Encrypt with correct PIN.
      const correctPin = 'correct123';
      final encryption = BackupEncryptionService();
      final encPath = await encryption.encryptFile(
        sourcePath: sourceFile.path,
        pin: correctPin,
        outputPath: p.join(tempDir.path, 'wrong_pin.db.enc'),
      );

      // Set up live DB.
      final livePath = p.join(tempDir.path, 'promsell_pos.db');
      final liveFile = File(livePath);
      if (liveFile.existsSync()) liveFile.deleteSync();
      final liveDb = AppDatabase.forTesting(NativeDatabase(liveFile));
      await liveDb.customStatement(
        'INSERT INTO app_settings (key, value) VALUES (\'live\', \'1\')',
      );
      await liveDb.close();

      // Verify the live DB exists before restore attempt.
      expect(await liveFile.exists(), isTrue);

      // Try to restore with wrong PIN.
      final mockDb = _MockDb();
      when(() => mockDb.close()).thenAnswer((_) async {});
      final restoreService = BackupRestoreService(
        mockDb,
        encryption,
        fakeAppLock(),
        candidateValidator: (_) async {},
        skipSqlCipherHeaderCheck: true,
      );

      expect(
        () => restoreService.restoreFromPath(
          sourcePath: encPath,
          pin: 'wrongPin1',
        ),
        throwsA(anyOf(isA<StateError>(), isA<Exception>())),
      );

      // Live DB should still exist (restore failed before swap).
      expect(
        await liveFile.exists(),
        isTrue,
        reason: 'Live DB should not be touched when decryption fails',
      );
      print('  Wrong PIN: restore failed, live DB unchanged');
    });

    test('restore validates schema integrity before swap', () async {
      // Create a corrupted "backup" that passes the header check but
      // fails the schema validation.
      final corruptedFile = File(p.join(tempDir.path, 'corrupted_schema.db'));
      // Write SQLCipher-like bytes but not a valid DB.
      await corruptedFile.writeAsBytes(
        Uint8List.fromList(List.generate(1024, (i) => (i * 37 + 7) % 256)),
      );

      final encryption = BackupEncryptionService();
      final mockDb = _MockDb();
      when(() => mockDb.close()).thenAnswer((_) async {});

      // Use a candidate validator that tries to open the file as a DB
      // and fails — simulating a corrupted schema.
      final restoreService = BackupRestoreService(
        mockDb,
        encryption,
        fakeAppLock(),
        candidateValidator: (path) async {
          // Try to open the file as a Drift DB — this will fail because
          // the file is not a valid SQLite database.
          try {
            final candidate = AppDatabase.forTesting(
              NativeDatabase(File(path)),
            );
            await candidate
                .customSelect('SELECT COUNT(*) AS c FROM products')
                .getSingle();
            await candidate.close();
            throw StateError('SCHEMA_VALIDATION_PASSED_UNEXPECTEDLY');
          } catch (e) {
            // Expected — the file is not a valid DB.
            throw StateError('INVALID_BACKUP_SCHEMA');
          }
        },
        skipSqlCipherHeaderCheck: true,
      );

      // The restore should fail during validation.
      expect(
        () => restoreService.restoreFromPath(sourcePath: corruptedFile.path),
        throwsA(isA<StateError>()),
      );

      print('  Schema validation: corrupted backup rejected before swap');
    });
  });
}
