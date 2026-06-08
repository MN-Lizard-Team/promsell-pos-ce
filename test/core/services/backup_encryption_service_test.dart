import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/services/backup_encryption_service.dart';

void main() {
  late BackupEncryptionService service;
  late Directory tempDir;

  setUp(() async {
    service = BackupEncryptionService();
    tempDir = await Directory.systemTemp.createTemp('backup_enc_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('BackupEncryptionService', () {
    test('encryptFile creates .enc file', () async {
      final sourcePath = '${tempDir.path}/test.db';
      await File(sourcePath).writeAsBytes([1, 2, 3, 4, 5]);

      final encPath = await service.encryptFile(
        sourcePath: sourcePath,
        pin: '1234',
      );

      expect(encPath, '$sourcePath.enc');
      expect(await File(encPath).exists(), isTrue);
      final encBytes = await File(encPath).readAsBytes();
      // salt(16) + nonce(12) + ciphertext+tag > original 5 bytes
      expect(encBytes.length, greaterThan(28));
    });

    test('decryptFile restores original content', () async {
      final sourcePath = '${tempDir.path}/roundtrip.db';
      final original = List.generate(256, (i) => i % 256);
      await File(sourcePath).writeAsBytes(original);

      final encPath = await service.encryptFile(
        sourcePath: sourcePath,
        pin: '5678',
      );

      final decPath = await service.decryptFile(
        sourcePath: encPath,
        pin: '5678',
      );

      final decrypted = await File(decPath).readAsBytes();
      expect(decrypted, equals(original));
    });

    test('wrong PIN fails to decrypt', () async {
      final sourcePath = '${tempDir.path}/wrong_pin.db';
      await File(sourcePath).writeAsBytes([10, 20, 30]);

      final encPath = await service.encryptFile(
        sourcePath: sourcePath,
        pin: 'correct',
      );

      expect(
        () => service.decryptFile(sourcePath: encPath, pin: 'wrong'),
        throwsA(isA<Exception>()),
      );
    });

    test('verifyPin returns true for correct PIN', () async {
      final sourcePath = '${tempDir.path}/verify.db';
      await File(sourcePath).writeAsBytes([1, 2, 3]);

      final encPath = await service.encryptFile(
        sourcePath: sourcePath,
        pin: 'abc',
      );

      final result = await service.verifyPin(sourcePath: encPath, pin: 'abc');
      expect(result, isTrue);
    });

    test('verifyPin returns false for wrong PIN', () async {
      final sourcePath = '${tempDir.path}/verify_wrong.db';
      await File(sourcePath).writeAsBytes([1, 2, 3]);

      final encPath = await service.encryptFile(
        sourcePath: sourcePath,
        pin: 'abc',
      );

      final result = await service.verifyPin(sourcePath: encPath, pin: 'xyz');
      expect(result, isFalse);
    });

    test('encryptFile throws for non-existent source', () async {
      expect(
        () => service.encryptFile(
          sourcePath: '${tempDir.path}/nonexistent.db',
          pin: '1234',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('decryptFile throws for too-short file', () async {
      final shortPath = '${tempDir.path}/short.enc';
      await File(shortPath).writeAsBytes([1, 2, 3]);

      expect(
        () => service.decryptFile(sourcePath: shortPath, pin: '1234'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
