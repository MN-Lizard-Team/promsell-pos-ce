import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Simple store PIN lock for sensitive POS actions (void, backup, PromptPay).
///
/// PIN is stored as SHA-256(salt || pin); never plain. Session unlock is
/// in-memory only (grace window).
@LazySingleton()
class AppLockService {
  AppLockService() : _storage = const FlutterSecureStorage();

  static const _pinHashKey = 'promsell_app_lock_pin_hash_v1';
  static const _pinSaltKey = 'promsell_app_lock_pin_salt_v1';
  static const _enabledKey = 'promsell_app_lock_enabled_v1';
  static const minPinLength = 4;
  static const sessionGrace = Duration(minutes: 2);

  final FlutterSecureStorage _storage;

  DateTime? _unlockedUntil;

  Future<bool> isEnabled() async {
    final v = await _storage.read(key: _enabledKey);
    return v == '1';
  }

  Future<bool> hasPin() async {
    final h = await _storage.read(key: _pinHashKey);
    return h != null && h.isNotEmpty;
  }

  /// Whether sensitive actions may proceed without re-prompt.
  bool get isSessionUnlocked {
    final until = _unlockedUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _unlockedUntil = null;
      return false;
    }
    return true;
  }

  void lockSession() {
    _unlockedUntil = null;
  }

  void unlockSession() {
    _unlockedUntil = DateTime.now().add(sessionGrace);
  }

  Future<void> setPin(String pin) async {
    final trimmed = pin.trim();
    if (trimmed.length < minPinLength) {
      throw StateError('PIN_TOO_SHORT');
    }
    final salt = _randomSalt();
    final hash = _hash(trimmed, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _enabledKey, value: '1');
    unlockSession();
  }

  Future<void> disable() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.write(key: _enabledKey, value: '0');
    lockSession();
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _pinSaltKey);
    final expected = await _storage.read(key: _pinHashKey);
    if (salt == null || expected == null) return false;
    final actual = _hash(pin.trim(), salt);
    final ok = actual == expected;
    if (ok) unlockSession();
    return ok;
  }

  /// Returns true if action may proceed (lock off, or session valid, or PIN ok).
  Future<bool> ensureUnlocked({String? pin}) async {
    if (!await isEnabled()) return true;
    if (isSessionUnlocked) return true;
    if (pin == null) return false;
    return verifyPin(pin);
  }

  String _hash(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin');
    return sha256.convert(bytes).toString();
  }

  String _randomSalt() {
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return '${now}_promsell_ce';
  }
}

