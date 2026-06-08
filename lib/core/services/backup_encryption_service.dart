import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:injectable/injectable.dart';

@LazySingleton()
class BackupEncryptionService {
  static const _keyLength = 32; // 256 bits
  static const _saltLength = 16;
  static const _nonceLength = 12; // 96 bits for GCM

  /// Encrypts a file using AES-256-GCM with a PIN-derived key.
  ///
  /// Returns the path to the encrypted (.enc) file.
  Future<String> encryptFile({
    required String sourcePath,
    required String pin,
    String? outputPath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Source file not found: $sourcePath');
    }

    final salt = _generateRandomBytes(_saltLength);
    final nonce = _generateRandomBytes(_nonceLength);
    final key = _deriveKey(pin, salt);

    final plaintext = await sourceFile.readAsBytes();
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = encrypter.encryptBytes(plaintext, iv: enc.IV(nonce));

    // Format: [salt(16)][nonce(12)][ciphertext+tag]
    final output = Uint8List.fromList([...salt, ...nonce, ...encrypted.bytes]);

    final targetPath = outputPath ?? '$sourcePath.enc';
    await File(targetPath).writeAsBytes(output);
    return targetPath;
  }

  /// Decrypts an encrypted backup file using AES-256-GCM.
  ///
  /// Returns the path to the decrypted file.
  Future<String> decryptFile({
    required String sourcePath,
    required String pin,
    String? outputPath,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Encrypted file not found: $sourcePath');
    }

    final data = await sourceFile.readAsBytes();
    if (data.length < _saltLength + _nonceLength) {
      throw StateError('Invalid encrypted file: too short');
    }

    final salt = Uint8List.sublistView(data, 0, _saltLength);
    final nonce = Uint8List.sublistView(
      data,
      _saltLength,
      _saltLength + _nonceLength,
    );
    final ciphertext = Uint8List.sublistView(data, _saltLength + _nonceLength);

    final key = _deriveKey(pin, salt);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = enc.Encrypted(ciphertext);
    final decrypted = encrypter.decryptBytes(encrypted, iv: enc.IV(nonce));

    final targetPath =
        outputPath ?? sourcePath.replaceAll('.enc', '.db.restored');
    await File(targetPath).writeAsBytes(decrypted);
    return targetPath;
  }

  /// Verifies a PIN against an encrypted file by attempting decryption.
  Future<bool> verifyPin({
    required String sourcePath,
    required String pin,
  }) async {
    try {
      await decryptFile(sourcePath: sourcePath, pin: pin);
      return true;
    } catch (_) {
      return false;
    }
  }

  enc.Key _deriveKey(String pin, Uint8List salt) {
    // PBKDF2 key derivation using HMAC-SHA256
    final hmac = Hmac(sha256, Uint8List.fromList(pin.codeUnits));
    var block = hmac.convert(salt).bytes;

    final keyBytes = List<int>.filled(_keyLength, 0);
    final copies = (_keyLength + block.length - 1) ~/ block.length;

    for (var i = 1; i < copies; i++) {
      block = hmac.convert(block).bytes;
    }

    for (var i = 0; i < _keyLength; i++) {
      keyBytes[i] = block[i % block.length];
    }

    return enc.Key(Uint8List.fromList(keyBytes));
  }

  Uint8List _generateRandomBytes(int length) {
    final random = enc.SecureRandom(length);
    return random.bytes;
  }
}
