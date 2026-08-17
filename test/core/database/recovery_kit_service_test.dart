import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/recovery_kit_service.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late _MockStorage storage;
  late RecoveryKitService service;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p1_recovery_kit_');
    // Stub secure storage channel.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            if (call.method == 'read') {
              return await storage.read(key: call.arguments['key'] as String);
            }
            if (call.method == 'write') {
              await storage.write(
                key: call.arguments['key'] as String,
                value: call.arguments['value'] as String,
              );
              return null;
            }
            if (call.method == 'delete') {
              await storage.delete(key: call.arguments['key'] as String);
              return null;
            }
            return null;
          },
        );
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() {
    storage = _MockStorage();
    final keyMap = <String, String>{};
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
      return keyMap[inv.namedArguments[#key] as String];
    });
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((inv) async {
      keyMap[inv.namedArguments[#key] as String] =
          inv.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((inv) async {
      keyMap.remove(inv.namedArguments[#key] as String);
    });

    service = RecoveryKitService();
    // Inject the mock storage by creating a subclass that uses it.
    // Since RecoveryKitService creates its own storage internally, we
    // test via the mock channel handler above.
  });

  group('P1-6: RecoveryKitService', () {
    test('export then import round-trips the key', () async {
      // This test uses the mock secure storage channel to simulate
      // a key being present, exported, wiped, and imported back.
      //
      // We can't easily mock DbKeyStore (it's static), so we test
      // the export/import file format directly with a known key.
      final testKey = 'a' * 64; // 32-byte hex key
      final kitPath = p.join(tempDir.path, 'test_roundtrip.promkey');

      // Manually create a kit file using the service's export logic
      // by first writing the key to secure storage.
      await const FlutterSecureStorage().write(
        key: 'promsell_db_key_v1',
        value: testKey,
      );

      final result = await service.exportKit(
        secret: 'testSecret123',
        outputPath: kitPath,
      );
      expect(result.filePath, kitPath);
      expect(result.metadata.version, 1);
      expect(await File(kitPath).exists(), isTrue);

      // Wipe the key.
      await const FlutterSecureStorage().delete(key: 'promsell_db_key_v1');

      // Import the kit.
      final importedKey = await service.importKit(
        filePath: kitPath,
        secret: 'testSecret123',
      );
      expect(importedKey, testKey);

      // Verify the key was installed in secure storage.
      final storedKey = await const FlutterSecureStorage().read(
        key: 'promsell_db_key_v1',
      );
      expect(storedKey, testKey);
    });

    test('wrong secret fails with WRONG_SECRET', () async {
      final testKey = 'b' * 64;
      final kitPath = p.join(tempDir.path, 'test_wrong_secret.promkey');

      await const FlutterSecureStorage().write(
        key: 'promsell_db_key_v1',
        value: testKey,
      );

      await service.exportKit(secret: 'correctSecret', outputPath: kitPath);

      // Wipe the key.
      await const FlutterSecureStorage().delete(key: 'promsell_db_key_v1');

      // Try to import with wrong secret.
      expect(
        () => service.importKit(filePath: kitPath, secret: 'wrongSecret'),
        throwsA(
          predicate((e) => e is StateError && e.message == 'WRONG_SECRET'),
        ),
      );
    });

    test('corrupt file fails with KIT_CORRUPT', () async {
      final kitPath = p.join(tempDir.path, 'corrupt.promkey');
      await File(kitPath).writeAsBytes([1, 2, 3]); // too short

      expect(
        () => service.importKit(filePath: kitPath, secret: 'testSecret123'),
        throwsA(
          predicate((e) => e is StateError && e.message == 'KIT_CORRUPT'),
        ),
      );
    });

    test('missing file fails with KIT_FILE_NOT_FOUND', () async {
      expect(
        () => service.importKit(
          filePath: '/nonexistent/path.promkey',
          secret: 'testSecret123',
        ),
        throwsA(
          predicate(
            (e) => e is StateError && e.message == 'KIT_FILE_NOT_FOUND',
          ),
        ),
      );
    });

    test('short secret fails with SECRET_TOO_SHORT on export', () async {
      expect(
        () => service.exportKit(secret: 'short'),
        throwsA(
          predicate((e) => e is StateError && e.message == 'SECRET_TOO_SHORT'),
        ),
      );
    });

    test('short secret fails with SECRET_TOO_SHORT on import', () async {
      final kitPath = p.join(tempDir.path, 'short_import.promkey');
      await File(kitPath).writeAsBytes(List.filled(100, 0));

      expect(
        () => service.importKit(filePath: kitPath, secret: 'short'),
        throwsA(
          predicate((e) => e is StateError && e.message == 'SECRET_TOO_SHORT'),
        ),
      );
    });

    test('tampered ciphertext fails with WRONG_SECRET', () async {
      final testKey = 'c' * 64;
      final kitPath = p.join(tempDir.path, 'tampered.promkey');

      await const FlutterSecureStorage().write(
        key: 'promsell_db_key_v1',
        value: testKey,
      );

      await service.exportKit(secret: 'testSecret123', outputPath: kitPath);

      // Tamper with the ciphertext (flip a byte near the end).
      final data = await File(kitPath).readAsBytes();
      data[data.length - 1] ^= 0xFF;
      await File(kitPath).writeAsBytes(data);

      // Wipe the key.
      await const FlutterSecureStorage().delete(key: 'promsell_db_key_v1');

      expect(
        () => service.importKit(filePath: kitPath, secret: 'testSecret123'),
        throwsA(
          predicate((e) => e is StateError && e.message == 'WRONG_SECRET'),
        ),
      );
    });

    test('hasKey returns true when key exists', () async {
      await const FlutterSecureStorage().write(
        key: 'promsell_db_key_v1',
        value: 'd' * 64,
      );
      expect(await service.hasKey(), isTrue);

      await const FlutterSecureStorage().delete(key: 'promsell_db_key_v1');
      expect(await service.hasKey(), isFalse);
    });

    test('removeKey deletes the key from secure storage', () async {
      await const FlutterSecureStorage().write(
        key: 'promsell_db_key_v1',
        value: 'e' * 64,
      );
      expect(await service.hasKey(), isTrue);

      await service.removeKey();
      expect(await service.hasKey(), isFalse);
    });
  });
}
