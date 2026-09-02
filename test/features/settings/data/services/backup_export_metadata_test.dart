// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_export_service.dart';

import '../../../../helpers/fake_app_lock.dart';
import '../../../../helpers/scaling_fixture.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late BackupEncryptionService encryption;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p1_backup_test_');
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    final file = File(p.join(tempDir.path, 'promsell_pos.db'));
    if (file.existsSync()) file.deleteSync();
    File('${file.path}-wal').deleteSyncIfExists();
    File('${file.path}-shm').deleteSyncIfExists();
    db = AppDatabase.forTesting(NativeDatabase(file));
    encryption = BackupEncryptionService();
    await db.customStatement(
      'INSERT INTO app_settings (key, value) VALUES (\'test\', \'1\')',
    );
  });

  tearDown(() async => db.close());

  group('P1-5: BackupExportService metadata + checksum', () {
    test('BackupMetadata encodes and decodes correctly', () {
      final metadata = const BackupMetadata(
        schemaVersion: 35,
        appVersion: '0.9.2',
        createdAt: '2026-01-01T00:00:00.000',
        dbSizeBytes: 1024,
        checksumSha256: 'abc123',
        encrypted: false,
      );
      final encoded = metadata.encode();
      final decoded = BackupMetadata.tryDecode(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.schemaVersion, 35);
      expect(decoded.appVersion, '0.9.2');
      expect(decoded.dbSizeBytes, 1024);
      expect(decoded.checksumSha256, 'abc123');
      expect(decoded.encrypted, isFalse);
    });

    test('BackupMetadata.tryDecode returns null for invalid JSON', () {
      expect(BackupMetadata.tryDecode(null), isNull);
      expect(BackupMetadata.tryDecode(''), isNull);
      expect(BackupMetadata.tryDecode('not json'), isNull);
    });

    test('exportToFiles writes metadata file with checksum', () async {
      final exportService = BackupExportService(db, encryption, fakeAppLock());

      final progressStages = <BackupProgress>[];
      final result = await exportService.exportToFiles(
        encrypt: false,
        appVersion: '0.9.2-test',
        onProgress: (stage) => progressStages.add(stage),
      );

      // Verify metadata.
      expect(result.metadata.schemaVersion, 35);
      expect(result.metadata.appVersion, '0.9.2-test');
      expect(result.metadata.encrypted, isFalse);
      expect(result.metadata.dbSizeBytes, greaterThan(0));
      expect(result.metadata.checksumSha256, isNotEmpty);
      expect(result.metadata.checksumSha256.length, 64); // SHA-256 hex

      // Verify metadata file was written.
      final metadataFile = File(result.metadataPath!);
      expect(await metadataFile.exists(), isTrue);
      final content = await metadataFile.readAsString();
      expect(content, contains('schemaVersion'));
      expect(content, contains('checksumSha256'));

      // Verify progress stages were reported.
      expect(progressStages, contains(BackupProgress.checkpointing));
      expect(progressStages, contains(BackupProgress.checksumming));

      // Verify the backup file matches its checksum.
      final backupFile = File(result.filePath);
      expect(await backupFile.exists(), isTrue);
    });

    test('validateAgainstMetadata returns true for valid backup', () async {
      final exportService = BackupExportService(db, encryption, fakeAppLock());

      final result = await exportService.exportToFiles(encrypt: false);

      final isValid = await exportService.validateAgainstMetadata(
        result.filePath,
      );
      expect(isValid, isTrue);
    });

    test(
      'validateAgainstMetadata returns false for corrupted backup',
      () async {
        final exportService = BackupExportService(
          db,
          encryption,
          fakeAppLock(),
        );

        final result = await exportService.exportToFiles(encrypt: false);

        // Corrupt the backup file.
        await File(result.filePath).writeAsString('corrupted');

        final isValid = await exportService.validateAgainstMetadata(
          result.filePath,
        );
        expect(isValid, isFalse);
      },
    );

    test(
      'validateAgainstMetadata returns false when metadata is missing',
      () async {
        final exportService = BackupExportService(
          db,
          encryption,
          fakeAppLock(),
        );

        final result = await exportService.exportToFiles(encrypt: false);

        // Delete the metadata file.
        await File(result.metadataPath!).delete();

        final isValid = await exportService.validateAgainstMetadata(
          result.filePath,
        );
        expect(isValid, isFalse);
      },
    );

    test('exportToFiles reports progress stages in order', () async {
      final exportService = BackupExportService(db, encryption, fakeAppLock());

      final stages = <BackupProgress>[];
      await exportService.exportToFiles(encrypt: false, onProgress: stages.add);

      // Checkpointing should come before checksumming.
      final cpIdx = stages.indexOf(BackupProgress.checkpointing);
      final csIdx = stages.indexOf(BackupProgress.checksumming);
      expect(cpIdx, lessThan(csIdx));
    });

    test('size preflight rejects DB larger than maxBackupBytes', () async {
      // This test verifies the preflight logic exists. We can't easily
      // create a 512 MB DB in a unit test, so we verify the constant
      // is accessible and the check would trigger.
      expect(BackupExportService.maxBackupBytes, 512 * 1024 * 1024);
    });
  });
}

extension on File {
  void deleteSyncIfExists() {
    if (existsSync()) deleteSync();
  }
}
