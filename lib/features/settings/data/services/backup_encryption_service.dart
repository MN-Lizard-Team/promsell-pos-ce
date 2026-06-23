import 'dart:convert';
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
  static const _v1 = 0x01;
  static const _v2 = 0x02;

  /// Encrypts a file using AES-256-GCM with a PIN-derived key.
  ///
  /// Format v2: [version(1)][salt(16)][nonce(12)][ciphertext+tag]
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
    final key = _deriveKey(pin, salt, _v2);

    final plaintext = await sourceFile.readAsBytes();
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = encrypter.encryptBytes(plaintext, iv: enc.IV(nonce));

    // Format v2: [version(1)][salt(16)][nonce(12)][ciphertext+tag]
    final output = Uint8List.fromList([
      _v2,
      ...salt,
      ...nonce,
      ...encrypted.bytes,
    ]);

    final targetPath = outputPath ?? '$sourcePath.enc';
    await File(targetPath).writeAsBytes(output);
    return targetPath;
  }

  /// Decrypts an encrypted backup file using AES-256-GCM.
  ///
  /// Supports both v2 (PBKDF2, 100K iterations) and v1 (legacy weak derivation).
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
    if (data.isEmpty) {
      throw StateError('Invalid encrypted file: empty');
    }

    int version;
    Uint8List salt;
    Uint8List nonce;
    Uint8List ciphertext;

    if (data[0] == _v2) {
      if (data.length < 1 + _saltLength + _nonceLength + 1) {
        throw StateError('Invalid encrypted file: too short');
      }
      version = _v2;
      salt = Uint8List.sublistView(data, 1, 1 + _saltLength);
      nonce = Uint8List.sublistView(
        data,
        1 + _saltLength,
        1 + _saltLength + _nonceLength,
      );
      ciphertext = Uint8List.sublistView(data, 1 + _saltLength + _nonceLength);
    } else {
      // Legacy v1 format (no version byte)
      if (data.length < _saltLength + _nonceLength) {
        throw StateError('Invalid encrypted file: too short');
      }
      version = _v1;
      salt = Uint8List.sublistView(data, 0, _saltLength);
      nonce = Uint8List.sublistView(
        data,
        _saltLength,
        _saltLength + _nonceLength,
      );
      ciphertext = Uint8List.sublistView(data, _saltLength + _nonceLength);
    }

    final key = _deriveKey(pin, salt, version);
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

  enc.Key _deriveKey(String pin, Uint8List salt, int version) {
    if (version == _v2) {
      return _pbkdf2(pin, salt, 100000, _keyLength);
    }
    return _deriveKeyV1(pin, salt);
  }

  /// Legacy weak key derivation (v1). Kept for backward compatibility.
  enc.Key _deriveKeyV1(String pin, Uint8List salt) {
    final hmac = Hmac(sha256, Uint8List.fromList(pin.codeUnits));
    var block = hmac.convert(salt).bytes;
    final copies = (_keyLength + block.length - 1) ~/ block.length;
    for (var i = 1; i < copies; i++) {
      block = hmac.convert(block).bytes;
    }
    final keyBytes = List<int>.filled(_keyLength, 0);
    for (var i = 0; i < _keyLength; i++) {
      keyBytes[i] = block[i % block.length];
    }
    return enc.Key(Uint8List.fromList(keyBytes));
  }

  /// PBKDF2-HMAC-SHA256 key derivation (RFC 2898).
  enc.Key _pbkdf2(
    String password,
    Uint8List salt,
    int iterations,
    int keyLength,
  ) {
    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final hmac = Hmac(sha256, passwordBytes);
    const blockLength = 32; // SHA-256 output length
    final blocksNeeded = (keyLength + blockLength - 1) ~/ blockLength;
    final result = <int>[];

    for (var blockIndex = 1; blockIndex <= blocksNeeded; blockIndex++) {
      // U_1 = HMAC(password, salt || INT_32_BE(blockIndex))
      final saltAndIndex = Uint8List(salt.length + 4);
      saltAndIndex.setAll(0, salt);
      saltAndIndex[salt.length] = (blockIndex >> 24) & 0xFF;
      saltAndIndex[salt.length + 1] = (blockIndex >> 16) & 0xFF;
      saltAndIndex[salt.length + 2] = (blockIndex >> 8) & 0xFF;
      saltAndIndex[salt.length + 3] = blockIndex & 0xFF;

      var u = hmac.convert(saltAndIndex).bytes;
      final block = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < block.length; j++) {
          block[j] ^= u[j];
        }
      }

      result.addAll(block);
    }

    return enc.Key(Uint8List.fromList(result.sublist(0, keyLength)));
  }

  Uint8List _generateRandomBytes(int length) {
    final random = enc.SecureRandom(length);
    return random.bytes;
  }
}
