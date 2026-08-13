import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/crypto_utils.dart';

/// Isolate payload for PBKDF2 key derivation.
class _Pbkdf2Params {
  const _Pbkdf2Params(
    this.password,
    this.salt,
    this.iterations,
    this.keyLength,
  );
  final String password;
  final Uint8List salt;
  final int iterations;
  final int keyLength;
}

/// Pure top-level PBKDF2-HMAC-SHA256 (RFC 2898) — runs inside an isolate
/// so the 100K-iteration loop does not block the UI thread.
/// Delegates to the shared [pbkdf2] implementation.
Uint8List _pbkdf2Isolate(_Pbkdf2Params params) {
  return pbkdf2(
    password: params.password,
    salt: params.salt,
    iterations: params.iterations,
    keyLength: params.keyLength,
  );
}

@LazySingleton()
class BackupEncryptionService {
  static const _keyLength = 32; // 256 bits
  static const _saltLength = 16;
  static const _nonceLength = 12; // 96 bits for GCM
  static const _v1 = 0x01;
  static const _v2 = 0x02;
  static const minPinLength = 6;
  static const maxFileBytes = 512 * 1024 * 1024;
  static const _pbkdf2Iterations = 100000;

  /// Encrypts a file using AES-256-GCM with a PIN-derived key.
  ///
  /// Format v2: [version(1)][salt(16)][nonce(12)][ciphertext+tag]
  /// Returns the path to the encrypted (.enc) file.
  Future<String> encryptFile({
    required String sourcePath,
    required String pin,
    String? outputPath,
  }) async {
    final trimmed = pin.trim();
    if (trimmed.isEmpty) {
      throw StateError('PIN_REQUIRED');
    }
    if (trimmed.length < minPinLength) {
      throw StateError('PIN_TOO_SHORT');
    }

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Source file not found: $sourcePath');
    }
    if (await sourceFile.length() > maxFileBytes) {
      throw StateError('BACKUP_TOO_LARGE');
    }

    final salt = _generateRandomBytes(_saltLength);
    final nonce = _generateRandomBytes(_nonceLength);
    final key = await _deriveKey(trimmed, salt, _v2);

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
    if (await sourceFile.length() > maxFileBytes) {
      throw StateError('BACKUP_TOO_LARGE');
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

    final key = await _deriveKey(pin, salt, version);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));

    final encrypted = enc.Encrypted(ciphertext);
    final decrypted = encrypter.decryptBytes(encrypted, iv: enc.IV(nonce));

    final targetPath =
        outputPath ?? sourcePath.replaceAll('.enc', '.db.restored');
    await File(targetPath).writeAsBytes(decrypted);
    return targetPath;
  }

  /// Verifies a PIN against an encrypted file by attempting decryption.
  ///
  /// Always deletes any temporary restored plaintext after the attempt.
  Future<bool> verifyPin({
    required String sourcePath,
    required String pin,
  }) async {
    String? restoredPath;
    try {
      restoredPath = await decryptFile(sourcePath: sourcePath, pin: pin);
      return true;
    } catch (e) {
      AppLogger.warning('Backup PIN verification failed', error: e);
      return false;
    } finally {
      if (restoredPath != null) {
        try {
          final f = File(restoredPath);
          if (await f.exists()) await f.delete();
        } catch (e, stack) {
          AppLogger.warning(
            'backup_encryption: cleanup of restored file failed',
            error: e,
            stack: stack,
          );
        }
      }
    }
  }

  Future<enc.Key> _deriveKey(String pin, Uint8List salt, int version) async {
    if (version == _v2) {
      final keyBytes = await _pbkdf2InIsolate(
        pin,
        salt,
        _pbkdf2Iterations,
        _keyLength,
      );
      return enc.Key(keyBytes);
    }
    return _deriveKeyV1(pin, salt);
  }

  /// Runs PBKDF2 in a background isolate to avoid blocking the UI.
  static Future<Uint8List> _pbkdf2InIsolate(
    String password,
    Uint8List salt,
    int iterations,
    int keyLength,
  ) async {
    final params = _Pbkdf2Params(password, salt, iterations, keyLength);
    return Isolate.run(() => _pbkdf2Isolate(params));
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

  Uint8List _generateRandomBytes(int length) {
    final random = enc.SecureRandom(length);
    return random.bytes;
  }
}
