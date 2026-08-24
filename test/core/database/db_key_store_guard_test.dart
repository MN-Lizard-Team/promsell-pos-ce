import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:promsell_pos_ce/core/database/db_key_store.dart';

/// POST-090-2b: key-loss guards in DbKeyStore.getOrCreateKey.
///
/// A fresh random key over an existing encrypted SQLCipher DB bricks that DB
/// permanently. These tests pin the three hazard paths:
/// 1. secure storage read throws -> typed [DbKeyUnavailable], never regenerate
/// 2. read null + no DB file (fresh install) -> generate + persist as before
/// 3. read null + encrypted DB present -> throw, never regenerate
class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.documentsPath);
  final String documentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => documentsPath;
}

class _ThrowingPathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    throw PlatformException(code: 'NO_DOCS', message: 'path provider broken');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  const dbKeyAlias = 'promsell_db_key_v1';
  final hexPattern = RegExp(r'^[0-9a-fA-F]{64}$');

  late Directory tempDir;
  late Directory docsDir;
  late Map<String, String> backing;
  bool failReads;

  setUp(() {
    // flutter_test defaults to Android; keep explicit so the desktop-debug
    // shortcut never triggers and we exercise the real storage path.
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tempDir = Directory.systemTemp.createTempSync('dbkey_guard_');
    docsDir = Directory(p.join(tempDir.path, 'docs'))..createSync();
    PathProviderPlatform.instance = _FakePathProviderPlatform(docsDir.path);

    backing = {};
    failReads = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          switch (call.method) {
            case 'read':
              if (failReads) {
                throw PlatformException(
                  code: 'user_rejected',
                  message: 'Android Keystore invalidated',
                );
              }
              return backing[call.arguments['key'] as String];
            case 'write':
              backing[call.arguments['key'] as String] =
                  call.arguments['value'] as String;
              return null;
            case 'delete':
              backing.remove(call.arguments['key'] as String);
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('DbKeyStore key-loss guards', () {
    test('storage read throw -> STORAGE_READ_FAILED, never writes', () async {
      failReads = true;

      await expectLater(
        DbKeyStore.getOrCreateKey(),
        throwsA(
          isA<DbKeyUnavailable>().having(
            (e) => e.code,
            'code',
            'STORAGE_READ_FAILED',
          ),
        ),
      );
      expect(backing, isEmpty, reason: 'must not mint a key on error path');
    });

    test(
      'null read with no DB file generates and persists a fresh key',
      () async {
        expect(
          docsDir.listSync(),
          isEmpty,
          reason: 'precondition: fresh install',
        );

        final key = await DbKeyStore.getOrCreateKey();

        expect(hexPattern.hasMatch(key), isTrue);
        expect(backing[dbKeyAlias], key, reason: 'generated key must persist');
      },
    );

    test(
      'null read with existing DB file throws KEY_MISSING_DB_PRESENT',
      () async {
        File(
          p.join(docsDir.path, 'promsell_pos.db'),
        ).writeAsBytesSync(List.filled(64, 0x9E));

        await expectLater(
          DbKeyStore.getOrCreateKey(),
          throwsA(
            isA<DbKeyUnavailable>().having(
              (e) => e.code,
              'code',
              'KEY_MISSING_DB_PRESENT',
            ),
          ),
        );
        expect(backing, isEmpty, reason: 'existing DB must not get a new key');
      },
    );

    test(
      'DB path resolution failure fails closed instead of generating',
      () async {
        PathProviderPlatform.instance = _ThrowingPathProviderPlatform();

        await expectLater(
          DbKeyStore.getOrCreateKey(),
          throwsA(isA<DbKeyUnavailable>()),
        );
        expect(backing, isEmpty);
      },
    );

    test(
      'existing stored key is returned without touching path provider',
      () async {
        backing[dbKeyAlias] = 'a' * 64;
        PathProviderPlatform.instance = _ThrowingPathProviderPlatform();

        final key = await DbKeyStore.getOrCreateKey();

        expect(key, 'a' * 64);
      },
    );

    test('desktop debug shortcut unchanged (fixed all-zero key)', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      final key = await DbKeyStore.getOrCreateKey();

      expect(key, '0' * 64);
      expect(backing, isEmpty);
    });
  });
}
