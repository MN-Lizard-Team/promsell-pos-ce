import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  /// Returns hex-encoded 32-byte (256-bit) encryption key.
  /// Generates and persists a new key on first call.
  static Future<String> getOrCreateKey() async {
    // On desktop (dev environment), return a fixed key to avoid Keystore dependency.
    // Production builds (Android/iOS) never hit this branch.
    if (kDebugMode && _isDesktop()) {
      return '0' * 64; // 32 zero bytes — dev-only, never production
    }

    var hex = await _storage.read(key: _keyAlias);
    if (hex == null) {
      final rng = Random.secure();
      final bytes = List.generate(32, (_) => rng.nextInt(256));
      hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      await _storage.write(key: _keyAlias, value: hex);
    }
    return hex;
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
