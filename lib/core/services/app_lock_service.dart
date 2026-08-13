import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/crypto_utils.dart';

/// Store PIN lock for sensitive POS actions
/// (void, backup, PromptPay, stock adjust, CSV import).
///
/// PIN is stored as a derived hash + salt in [FlutterSecureStorage] — never
/// plain text. Session unlock is in-memory only ([sessionGrace]).
/// Failed-attempt lockout is persisted so cold start cannot reset brute force.
///
/// Domain use cases should call [requireSensitiveSession] so gates are not
/// UI-only (POST-090 E0c). UI still prompts via [ensureUnlocked] / PIN dialog.
///
/// Scheme:
/// - **v2** (current): PBKDF2-HMAC-SHA256, 100k iterations, 32-byte key
/// - **v1** (legacy): SHA-256(`salt::pin`) — verified once then upgraded to v2
@LazySingleton()
class AppLockService {
  /// Thrown / used as [BusinessRuleError.rule] when lock is on and session cold.
  static const ruleAppLockRequired = 'AppLockRequired';
  AppLockService({@ignoreParam FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );

  static const _pinHashKey = 'promsell_app_lock_pin_hash_v1';
  static const _pinSaltKey = 'promsell_app_lock_pin_salt_v1';
  static const _enabledKey = 'promsell_app_lock_enabled_v1';
  static const _schemeKey = 'promsell_app_lock_pin_scheme_v1';
  static const _failedAttemptsKey = 'promsell_app_lock_failed_attempts_v1';
  static const _lockedUntilKey = 'promsell_app_lock_locked_until_ms_v1';

  /// Aligns with backup export PIN policy.
  static const minPinLength = 6;

  static const sessionGrace = Duration(minutes: 2);

  /// Failed attempts before temporary lockout.
  static const maxFailedAttempts = 5;

  /// Initial lockout after [maxFailedAttempts]; doubles each subsequent fail.
  static const baseLockout = Duration(seconds: 30);

  static const _pbkdf2Iterations = 100000;
  static const _keyLength = 32;
  static const _schemeV1 = 'v1';
  static const _schemeV2 = 'v2';

  final FlutterSecureStorage _storage;

  DateTime? _unlockedUntil;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;
  bool _lockoutHydrated = false;

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

  /// Remaining lockout after too many wrong PINs; null if not locked.
  ///
  /// Call [ensureLockoutHydrated] first after cold start if reading before
  /// [verifyPin].
  Duration? get lockoutRemaining {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(DateTime.now());
    if (left.isNegative) {
      // Memory only; storage is cleared on next hydrate/verify/setPin.
      _lockedUntil = null;
      _failedAttempts = 0;
      return null;
    }
    return left;
  }

  bool get isLockedOut => lockoutRemaining != null;

  void lockSession() {
    _unlockedUntil = null;
  }

  void unlockSession() {
    _unlockedUntil = DateTime.now().add(sessionGrace);
  }

  /// Loads persisted lockout counters once (cold start).
  Future<void> ensureLockoutHydrated() => _hydrateLockout();

  Future<void> setPin(String pin) async {
    final trimmed = pin.trim();
    if (trimmed.length < minPinLength) {
      throw StateError('PIN_TOO_SHORT');
    }
    // Guard: refuse to overwrite an existing PIN without verification.
    // Callers that need to change an existing PIN must use [changePin].
    if (await hasPin()) {
      throw StateError('PIN_ALREADY_SET');
    }
    await _writePin(trimmed);
  }

  /// Changes the PIN after verifying the current PIN.
  ///
  /// Throws `PIN_WRONG` if [currentPin] does not match the stored hash.
  /// Throws `PIN_LOCKED` if the lockout is active.
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final ok = await verifyPin(currentPin);
    if (!ok) throw StateError('PIN_WRONG');
    final trimmed = newPin.trim();
    if (trimmed.length < minPinLength) {
      throw StateError('PIN_TOO_SHORT');
    }
    await _writePin(trimmed);
  }

  Future<void> _writePin(String trimmed) async {
    final salt = _randomSalt();
    final hash = _hashV2(trimmed, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _schemeKey, value: _schemeV2);
    await _storage.write(key: _enabledKey, value: '1');
    _failedAttempts = 0;
    _lockedUntil = null;
    _lockoutHydrated = true;
    await _persistLockout();
    unlockSession();
  }

  Future<void> disable() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _schemeKey);
    await _storage.write(key: _enabledKey, value: '0');
    _failedAttempts = 0;
    _lockedUntil = null;
    _lockoutHydrated = true;
    await _persistLockout();
    lockSession();
  }

  /// Verifies [pin]. Returns false on mismatch or active lockout.
  ///
  /// Throws [StateError] with message `PIN_LOCKED` when lockout is active
  /// (callers may inspect [lockoutRemaining]).
  Future<bool> verifyPin(String pin) async {
    await _hydrateLockout();
    if (isLockedOut) {
      throw StateError('PIN_LOCKED');
    }
    final salt = await _storage.read(key: _pinSaltKey);
    final expected = await _storage.read(key: _pinHashKey);
    if (salt == null || expected == null) return false;

    final scheme = await _storage.read(key: _schemeKey) ?? _schemeV1;
    final trimmed = pin.trim();
    final ok = scheme == _schemeV2
        ? _hashV2(trimmed, salt) == expected
        : _hashV1(trimmed, salt) == expected;

    if (!ok) {
      await _registerFailure();
      return false;
    }

    _failedAttempts = 0;
    _lockedUntil = null;
    await _persistLockout();
    // Upgrade legacy hashes on successful unlock.
    if (scheme != _schemeV2) {
      await _writePin(trimmed);
    } else {
      unlockSession();
    }
    return true;
  }

  /// Returns true if action may proceed (lock off, or session valid, or PIN ok).
  Future<bool> ensureUnlocked({String? pin}) async {
    if (!await isEnabled()) return true;
    if (isSessionUnlocked) return true;
    if (pin == null) return false;
    try {
      return await verifyPin(pin);
    } on StateError catch (e) {
      if (e.message == 'PIN_LOCKED') return false;
      rethrow;
    }
  }

  /// Domain gate: fails closed when store PIN is enabled and session is locked.
  ///
  /// Call after UI unlock (or when lock is disabled). Does not accept a PIN —
  /// callers must [verifyPin] / [unlockSession] first.
  Future<void> requireSensitiveSession() async {
    if (!await isEnabled()) return;
    if (isSessionUnlocked) return;
    throw const BusinessRuleError(ruleAppLockRequired);
  }

  Future<void> _hydrateLockout() async {
    if (_lockoutHydrated) return;
    _lockoutHydrated = true;
    final attemptsRaw = await _storage.read(key: _failedAttemptsKey);
    final untilRaw = await _storage.read(key: _lockedUntilKey);
    _failedAttempts = int.tryParse(attemptsRaw ?? '') ?? 0;
    if (untilRaw != null && untilRaw.isNotEmpty) {
      final ms = int.tryParse(untilRaw);
      if (ms != null) {
        final until = DateTime.fromMillisecondsSinceEpoch(ms);
        if (until.isAfter(DateTime.now())) {
          _lockedUntil = until;
        } else {
          _lockedUntil = null;
          _failedAttempts = 0;
          await _persistLockout();
        }
      }
    }
  }

  Future<void> _persistLockout() async {
    if (_failedAttempts <= 0 && _lockedUntil == null) {
      await _storage.delete(key: _failedAttemptsKey);
      await _storage.delete(key: _lockedUntilKey);
      return;
    }
    await _storage.write(key: _failedAttemptsKey, value: '$_failedAttempts');
    final until = _lockedUntil;
    if (until == null) {
      await _storage.delete(key: _lockedUntilKey);
    } else {
      await _storage.write(
        key: _lockedUntilKey,
        value: '${until.millisecondsSinceEpoch}',
      );
    }
  }

  Future<void> _registerFailure() async {
    _failedAttempts++;
    if (_failedAttempts >= maxFailedAttempts) {
      final multiplier = 1 << (_failedAttempts - maxFailedAttempts).clamp(0, 4);
      _lockedUntil = DateTime.now().add(
        Duration(seconds: baseLockout.inSeconds * multiplier),
      );
    }
    await _persistLockout();
  }

  String _hashV1(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin');
    return sha256.convert(bytes).toString();
  }

  String _hashV2(String pin, String salt) {
    final saltBytes = Uint8List.fromList(utf8.encode(salt));
    final key = pbkdf2(
      password: pin,
      salt: saltBytes,
      iterations: _pbkdf2Iterations,
      keyLength: _keyLength,
    );
    return key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _randomSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
