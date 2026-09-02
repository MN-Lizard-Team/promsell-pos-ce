import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// Typed failure when the SQLCipher key cannot be provided safely.
///
/// Thrown instead of silently generating a replacement key, because a fresh
/// random key makes an existing encrypted database permanently unreadable.
/// Catch this and guide the user toward Settings → Backup → Import recovery
/// kit (`RecoveryKitService.importKit`).
///
/// [code] values:
/// - `STORAGE_READ_FAILED`: platform secure storage threw while reading the
///   key (e.g. Android Keystore invalidated). Never regenerate on this path.
/// - `KEY_MISSING_DB_PRESENT`: no stored key, but an encrypted database file
///   already exists — regenerating would brick it.
/// - `DB_PATH_CHECK_FAILED`: could not determine whether a database file
///   exists. Fail closed rather than risk minting a key over live data.
class DbKeyUnavailable implements Exception {
  const DbKeyUnavailable(this.code);

  final String code;

  @override
  String toString() => 'DbKeyUnavailable: $code';
}

/// Secure key management for SQLite database encryption (Phase 2a / v0.9.0).
///
/// Generates a 256-bit (32-byte) AES key on first launch and persists it
/// securely using platform-native storage:
/// - Android: platform secure storage (Keystore-backed ciphers)
/// - iOS: Keychain (`unlocked_this_device`)
/// - Desktop (dev only): fixed dev key to avoid Keystore dependency
///
/// The key is hex-encoded for use with SQLCipher's `PRAGMA key="x'...'"`
class DbKeyStore {
  DbKeyStore._();

  static const _keyAlias = 'promsell_db_key_v1';

  /// Must match [EncryptedDatabaseOpener._dbName] and every other service that
  /// resolves the database path (`backup_export_service`,
  /// `migration_safety_service`, `wal_checkpoint_service`,
  /// `database_health_service`).
  static const _dbName = 'promsell_pos.db';

  static const _storage = FlutterSecureStorage(
    // resetOnError: false — never let the plugin wipe the SQLCipher key on
    // Keystore errors (V092-B.7). A read failure surfaces as
    // [DbKeyUnavailable] so the user can restore via recovery kit instead of
    // silently losing the database.
    aOptions: AndroidOptions(resetOnError: false),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  /// Returns hex-encoded 32-byte (256-bit) encryption key.
  /// Generates and persists a new key on first call.
  ///
  /// Throws [DbKeyUnavailable] when no key exists but generating one would
  /// make existing encrypted data unreadable, or when secure storage fails.
  /// Callers ([EncryptedDatabaseOpener.open], backup/restore, recovery kit)
  /// await this on the main isolate before any isolate spawn, so the typed
  /// error surfaces as a normal catchable async DB-open failure.
  static Future<String> getOrCreateKey() async {
    // On desktop (dev environment), return a fixed key to avoid Keystore dependency.
    // Production builds (Android/iOS) never hit this branch.
    if (kDebugMode && _isDesktop()) {
      return '0' * 64; // 32 zero bytes — dev-only, never production
    }

    final String? hex;
    try {
      hex = await _storage.read(key: _keyAlias);
    } catch (e, st) {
      AppLogger.warning(
        'DbKeyStore: secure storage read failed for $_keyAlias',
        error: e,
        stack: st,
      );
      throw const DbKeyUnavailable('STORAGE_READ_FAILED');
    }
    if (hex != null && hex.isNotEmpty) return hex;

    // No usable stored key. Minting a new one is only safe when no encrypted
    // database file exists yet (fresh install); otherwise the existing DB
    // becomes permanently unopenable.
    if (!await _isSafeToGenerateKey()) {
      throw const DbKeyUnavailable('KEY_MISSING_DB_PRESENT');
    }

    final rng = Random.secure();
    final bytes = List.generate(32, (_) => rng.nextInt(256));
    final newHex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _keyAlias, value: newHex);
    return newHex;
  }

  /// True only when we can prove there is no database to lose.
  ///
  /// Best-effort check of `<ApplicationDocumentsDirectory>/$_dbName` — the
  /// same location logic as `EncryptedDatabaseOpener`. Any failure resolving
  /// or probing the path fails closed (returns false).
  static Future<bool> _isSafeToGenerateKey() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(docs.path, _dbName));
      return !await dbFile.exists();
    } catch (e, st) {
      AppLogger.warning(
        'DbKeyStore: DB existence check failed; refusing to generate a key',
        error: e,
        stack: st,
      );
      return false;
    }
  }

  static bool _isDesktop() {
    try {
      return !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS);
    } catch (_) {
      return false;
    }
  }
}
