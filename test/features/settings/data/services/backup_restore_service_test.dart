import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_export_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_restore_service.dart';

class _MockDb extends Mock implements AppDatabase {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

/// Lock disabled (no enabled flag) — domain gate allows.
AppLockService _unlockedAppLock() {
  final map = <String, String>{};
  final storage = _MockStorage();
  when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
    return map[inv.namedArguments[#key] as String];
  });
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((inv) async {
    map[inv.namedArguments[#key] as String] =
        inv.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key'))).thenAnswer((inv) async {
    map.remove(inv.namedArguments[#key] as String);
  });
  return AppLockService(storage: storage);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late BackupRestoreService service;
  late BackupEncryptionService encryption;
  late _MockDb db;

  void mockPathProvider(Directory root) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            switch (call.method) {
              case 'getApplicationDocumentsDirectory':
                return p.join(root.path, 'docs');
              case 'getTemporaryDirectory':
                return p.join(root.path, 'tmp');
              default:
                return null;
            }
          },
        );
  }

  /// Bytes that look like SQLCipher (not plain "SQLite format 3" header).
  Uint8List sqlCipherLikePayload([int len = 128]) {
    return Uint8List.fromList(
      List<int>.generate(len, (i) => (i * 17 + 3) % 256),
    );
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('promsell_restore_test');
    await Directory(p.join(temp.path, 'docs')).create(recursive: true);
    await Directory(p.join(temp.path, 'tmp')).create(recursive: true);
    mockPathProvider(temp);
    db = _MockDb();
    when(() => db.close()).thenAnswer((_) async {});
    encryption = BackupEncryptionService();
    service = BackupRestoreService(
      db,
      encryption,
      _unlockedAppLock(),
      candidateValidator: (_) async {},
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('missing source throws SOURCE_MISSING', () async {
    expect(
      () => service.restoreFromPath(sourcePath: p.join(temp.path, 'nope.db')),
      throwsA(
        isA<StateError>().having((e) => e.message, 'm', 'SOURCE_MISSING'),
      ),
    );
  });

  test('enc without pin throws PIN_REQUIRED before path_provider', () async {
    final f = File(p.join(temp.path, 'x.enc'));
    await f.writeAsBytes(List.filled(64, 1));
    expect(
      () => service.restoreFromPath(sourcePath: f.path),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_REQUIRED')),
    );
  });

  test('plain SQLite header is rejected as PLAIN_SQLITE_UNSUPPORTED', () async {
    final f = File(p.join(temp.path, 'plain.db'));
    // "SQLite format 3\0" is 16 bytes.
    await f.writeAsBytes([...utf8.encode('SQLite format 3'), 0]);
    expect(
      () => service.restoreFromPath(sourcePath: f.path),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'm',
          'PLAIN_SQLITE_UNSUPPORTED',
        ),
      ),
    );
  });

  test(
    'full round-trip: encrypt SQLCipher-like DB → restore .enc → live file + pre_restore',
    () async {
      const pin = '123456';
      final original = sqlCipherLikePayload(256);

      // 1) Source "live" DB snapshot that would be exported.
      final exportSource = File(p.join(temp.path, 'export_source.db'));
      await exportSource.writeAsBytes(original);

      // 2) Encrypt (same service used by backup export).
      final encPath = await encryption.encryptFile(
        sourcePath: exportSource.path,
        pin: pin,
      );
      expect(encPath.endsWith('.enc'), isTrue);
      expect(await File(encPath).exists(), isTrue);

      // 3) Existing live DB that must be preserved as pre_restore.
      final docs = p.join(temp.path, 'docs');
      final livePath = p.join(docs, BackupExportService.dbFileName);
      final liveBefore = Uint8List.fromList(
        List<int>.generate(64, (i) => 200 + (i % 40)),
      );
      await File(livePath).writeAsBytes(liveBefore);
      // Stale WAL/SHM should be removed after restore.
      await File('$livePath-wal').writeAsBytes([1, 2, 3]);
      await File('$livePath-shm').writeAsBytes([4, 5, 6]);

      // 4) Restore from encrypted package.
      final preRestorePath = await service.restoreFromPath(
        sourcePath: encPath,
        pin: pin,
      );

      verify(() => db.close()).called(1);

      // Live DB replaced with original plaintext SQLCipher payload.
      final liveAfter = await File(livePath).readAsBytes();
      expect(liveAfter, equals(original));

      // Pre-restore backup holds previous live bytes.
      expect(preRestorePath, contains('promsell_pos.pre_restore_'));
      expect(await File(preRestorePath).exists(), isTrue);
      expect(await File(preRestorePath).readAsBytes(), equals(liveBefore));

      // WAL/SHM purged.
      expect(await File('$livePath-wal').exists(), isFalse);
      expect(await File('$livePath-shm').exists(), isFalse);
    },
  );

  test(
    'sqlcipher .db restore without PIN replaces live and keeps pre_restore',
    () async {
      final original = sqlCipherLikePayload(96);
      final backupDb = File(p.join(temp.path, 'backup.db'));
      await backupDb.writeAsBytes(original);

      final docs = p.join(temp.path, 'docs');
      final livePath = p.join(docs, BackupExportService.dbFileName);
      final liveBefore = Uint8List.fromList([9, 8, 7, 6, 5]);
      await File(livePath).writeAsBytes(liveBefore);

      final pre = await service.restoreFromPath(sourcePath: backupDb.path);

      final liveAfter = await File(livePath).readAsBytes();
      expect(liveAfter, equals(original));
      expect(await File(pre).readAsBytes(), equals(liveBefore));
      verify(() => db.close()).called(1);
    },
  );

  test('invalid candidate is rejected before closing the live DB', () async {
    final invalidService = BackupRestoreService(
      db,
      encryption,
      _unlockedAppLock(),
      candidateValidator: (_) async =>
          throw StateError('INVALID_BACKUP_SCHEMA'),
    );
    final backup = File(p.join(temp.path, 'invalid.db'));
    await backup.writeAsBytes(sqlCipherLikePayload());

    await expectLater(
      () => invalidService.restoreFromPath(sourcePath: backup.path),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'm',
          'INVALID_BACKUP_SCHEMA',
        ),
      ),
    );
    verifyNever(() => db.close());
  });

  test('wrong PIN on .enc fails and leaves live DB unchanged', () async {
    final original = sqlCipherLikePayload(80);
    final exportSource = File(p.join(temp.path, 'export2.db'));
    await exportSource.writeAsBytes(original);
    final encPath = await encryption.encryptFile(
      sourcePath: exportSource.path,
      pin: 'goodpin',
    );

    final docs = p.join(temp.path, 'docs');
    final livePath = p.join(docs, BackupExportService.dbFileName);
    final liveBefore = Uint8List.fromList([1, 1, 1, 1]);
    await File(livePath).writeAsBytes(liveBefore);

    await expectLater(
      () => service.restoreFromPath(sourcePath: encPath, pin: 'badpin1'),
      throwsA(anything),
    );

    expect(await File(livePath).readAsBytes(), equals(liveBefore));
  });
}
