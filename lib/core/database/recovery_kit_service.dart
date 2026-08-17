import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/db_key_store.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/crypto_utils.dart';

/// Recovery kit file format version.
const int kRecoveryKitVersion = 1;

/// File extension for recovery kit files.
const String kRecoveryKitExtension = '.promkey';

/// Minimum secret length for recovery kit (stricter than store PIN per D0-Q3).
const int kRecoveryKitMinSecretLength = 8;

/// PBKDF2 iterations for recovery kit key derivation (aligns with backup PIN).
const int _pbkdf2Iterations = 100000;

/// Salt length in bytes.
const int _saltLength = 16;

/// Nonce length in bytes (96 bits for GCM).
const int _nonceLength = 12;

/// Key length in bytes (256 bits).
const int _keyLength = 32;

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
Uint8List _pbkdf2Isolate(_Pbkdf2Params params) {
  return pbkdf2(
    password: params.password,
    salt: params.salt,
    iterations: params.iterations,
    keyLength: params.keyLength,
  );
}

/// Result of a recovery kit export.
class RecoveryKitExportResult {
  const RecoveryKitExportResult({
    required this.filePath,
    required this.metadata,
  });

  final String filePath;
  final RecoveryKitMetadata metadata;
}

/// Metadata embedded in the recovery kit file header.
class RecoveryKitMetadata {
  const RecoveryKitMetadata({
    required this.version,
    required this.createdAt,
    required this.kdfIterations,
  });

  final int version;
  final String createdAt;
  final int kdfIterations;

  Map<String, dynamic> toJson() => {
    'version': version,
    'createdAt': createdAt,
    'kdfIterations': kdfIterations,
  };

  factory RecoveryKitMetadata.fromJson(Map<String, dynamic> json) =>
      RecoveryKitMetadata(
        version: json['version'] as int? ?? 1,
        createdAt: json['createdAt'] as String? ?? '',
        kdfIterations: json['kdfIterations'] as int? ?? _pbkdf2Iterations,
      );
}

/// Service for exporting and importing the SQLCipher key as a recovery kit.
///
/// **Export:** Wraps the SQLCipher key with AES-256-GCM using a
/// PBKDF2-derived key from the user's passphrase. The output file format is:
/// ```
/// [version(1)][salt(16)][nonce(12)][ciphertext+tag]
/// ```
///
/// **Import:** Unwraps the key using the passphrase and installs it into
/// the platform secure storage (Keystore/Keychain).
///
/// **Threat model (D0):**
/// - Anyone with the kit file + secret can read all sales/customer data.
/// - PBKDF2-HMAC-SHA256 ≥ 100K iterations; min secret length 8.
/// - Old kits remain valid until the DB key is changed (not in 2b v1).
///
/// See `docs/plan/COMPLETE/POST-090-MANAGE/WS-D-PHASE-2B-KEY-RESTORE.md`
/// for the full D0/D1 spec.
@LazySingleton()
class RecoveryKitService {
  RecoveryKitService();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  /// Exports the SQLCipher key as a password-wrapped recovery kit.
  ///
  /// [secret] must be at least [kRecoveryKitMinSecretLength] characters.
  /// [outputPath] defaults to a temp file with `.promkey` extension.
  ///
  /// Throws [StateError] with codes:
  /// - `SECRET_TOO_SHORT` if secret is shorter than minimum.
  /// - `NO_DB_KEY` if no SQLCipher key exists on this device.
  Future<RecoveryKitExportResult> exportKit({
    required String secret,
    String? outputPath,
  }) async {
    final trimmed = secret.trim();
    if (trimmed.length < kRecoveryKitMinSecretLength) {
      throw StateError('SECRET_TOO_SHORT');
    }

    final hexKey = await DbKeyStore.getOrCreateKey();
    if (hexKey.isEmpty) {
      throw StateError('NO_DB_KEY');
    }

    // Derive wrapping key from passphrase.
    final salt = _generateRandomBytes(_saltLength);
    final nonce = _generateRandomBytes(_nonceLength);
    final wrapKey = await _deriveKey(trimmed, salt);

    // Encrypt the hex-encoded SQLCipher key.
    final plaintext = Uint8List.fromList(utf8.encode(hexKey));
    final encrypter = enc.Encrypter(enc.AES(wrapKey, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encryptBytes(plaintext, iv: enc.IV(nonce));

    // Build file: [version(1)][salt(16)][nonce(12)][ciphertext+tag]
    final metadata = RecoveryKitMetadata(
      version: kRecoveryKitVersion,
      createdAt: DateTime.now().toIso8601String(),
      kdfIterations: _pbkdf2Iterations,
    );

    final headerJson = utf8.encode(jsonEncode(metadata.toJson()));
    final headerLength = headerJson.length;

    final output = Uint8List.fromList([
      ..._uint32Bytes(headerLength),
      ...headerJson,
      ...salt,
      ...nonce,
      ...encrypted.bytes,
    ]);

    final path = outputPath ?? _defaultOutputPath();
    await File(path).writeAsBytes(output);

    AppLogger.info(
      'RecoveryKitService: exported kit to $path '
      '(version=${metadata.version}, kdf=${metadata.kdfIterations})',
    );

    return RecoveryKitExportResult(filePath: path, metadata: metadata);
  }

  /// Imports a recovery kit and installs the key into secure storage.
  ///
  /// [secret] is the passphrase used during export.
  ///
  /// Throws [StateError] with codes:
  /// - `SECRET_TOO_SHORT` if secret is shorter than minimum.
  /// - `KIT_FILE_NOT_FOUND` if the file doesn't exist.
  /// - `KIT_CORRUPT` if the file is malformed.
  /// - `KIT_VERSION_UNSUPPORTED` if the version is not recognized.
  /// - `WRONG_SECRET` if the passphrase is incorrect (GCM auth tag fail).
  /// - `KEY_ALREADY_EXISTS` if a key is already installed (call [replaceKey] first).
  Future<String> importKit({
    required String filePath,
    required String secret,
    bool replaceExisting = false,
  }) async {
    final trimmed = secret.trim();
    if (trimmed.length < kRecoveryKitMinSecretLength) {
      throw StateError('SECRET_TOO_SHORT');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('KIT_FILE_NOT_FOUND');
    }

    final data = await file.readAsBytes();
    if (data.length < 4 + _saltLength + _nonceLength + 16) {
      throw StateError('KIT_CORRUPT');
    }

    // Parse header.
    final headerLength = _bytesToUint32(data.sublist(0, 4));
    if (headerLength <= 0 || 4 + headerLength > data.length) {
      throw StateError('KIT_CORRUPT');
    }

    final headerJson = utf8.decode(data.sublist(4, 4 + headerLength));
    RecoveryKitMetadata metadata;
    try {
      metadata = RecoveryKitMetadata.fromJson(
        jsonDecode(headerJson) as Map<String, dynamic>,
      );
    } catch (e) {
      throw StateError('KIT_CORRUPT');
    }

    if (metadata.version > kRecoveryKitVersion) {
      throw StateError('KIT_VERSION_UNSUPPORTED');
    }

    final offset = 4 + headerLength;
    final salt = Uint8List.sublistView(data, offset, offset + _saltLength);
    final nonce = Uint8List.sublistView(
      data,
      offset + _saltLength,
      offset + _saltLength + _nonceLength,
    );
    final ciphertext = Uint8List.sublistView(
      data,
      offset + _saltLength + _nonceLength,
    );

    // Derive key and decrypt.
    final wrapKey = await _deriveKey(trimmed, salt);
    final encrypter = enc.Encrypter(enc.AES(wrapKey, mode: enc.AESMode.gcm));

    try {
      final decrypted = encrypter.decryptBytes(
        enc.Encrypted(ciphertext),
        iv: enc.IV(nonce),
      );
      final hexKey = utf8.decode(decrypted);

      // Check if key already exists.
      final existing = await _storage.read(key: 'promsell_db_key_v1');
      if (existing != null && !replaceExisting) {
        throw StateError('KEY_ALREADY_EXISTS');
      }

      // Install key into secure storage.
      await _storage.write(key: 'promsell_db_key_v1', value: hexKey);

      AppLogger.info(
        'RecoveryKitService: imported kit (version=${metadata.version})',
      );
      return hexKey;
    } catch (e, st) {
      if (e is StateError) rethrow;
      // GCM auth tag failure = wrong secret.
      AppLogger.warning(
        'RecoveryKitService: decryption failed (wrong secret or corrupt)',
        error: e,
        stack: st,
      );
      throw StateError('WRONG_SECRET');
    }
  }

  /// Checks whether a DB key is already installed on this device.
  Future<bool> hasKey() async {
    final key = await _storage.read(key: 'promsell_db_key_v1');
    return key != null && key.isNotEmpty;
  }

  /// Removes the existing DB key. Use with caution — the database becomes
  /// unreadable until a new key is imported.
  Future<void> removeKey() async {
    await _storage.delete(key: 'promsell_db_key_v1');
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Future<enc.Key> _deriveKey(String password, Uint8List salt) async {
    final keyBytes = await Isolate.run(
      () => _pbkdf2Isolate(
        _Pbkdf2Params(password, salt, _pbkdf2Iterations, _keyLength),
      ),
    );
    return enc.Key(keyBytes);
  }

  String _defaultOutputPath() {
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    // Use system temp — the caller will move it via share sheet.
    final dir = Directory.systemTemp;
    return '${dir.path}/promsell_recovery_kit_$stamp$kRecoveryKitExtension';
  }

  Uint8List _generateRandomBytes(int length) {
    final random = enc.SecureRandom(length);
    return random.bytes;
  }

  Uint8List _uint32Bytes(int value) {
    return Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.big);
  }

  int _bytesToUint32(Uint8List bytes) {
    return bytes.buffer.asByteData().getUint32(0, Endian.big);
  }
}
