import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/services/lockout_policy.dart';
import 'package:promsell_pos_ce/core/services/pin_hasher.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

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
            // resetOnError: false — lockout state and PIN material must never
            // be silently wiped on Keystore errors (V092-B.7); failures are
            // handled by the read guards below instead.
            aOptions: AndroidOptions(resetOnError: false),
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
  static const _pinSetAtKey = 'promsell_app_lock_pin_set_at_ms_v1';
  static const _sessionGraceSecondsKey = 'promsell_app_lock_session_grace_s_v1';
  static const _maxFailedAttemptsKey = 'promsell_app_lock_max_failed_v1';
  static const _baseLockoutSecondsKey = 'promsell_app_lock_base_lockout_s_v1';

  /// Hard minimum PIN length — not configurable.
  static const minPinLength = 6;

  /// Default session unlock grace (2 minutes).
  static const defaultSessionGrace = Duration(minutes: 2);

  /// Default failed attempts before temporary lockout.
  static const defaultMaxFailedAttempts =
      LockoutPolicy.defaultMaxFailedAttempts;

  /// Default initial lockout; doubles each subsequent fail.
  static const defaultBaseLockout = LockoutPolicy.defaultBaseLockout;

  /// Allowed session grace options (seconds) for the settings UI.
  static const sessionGraceOptionsSeconds = [0, 30, 60, 120, 300];

  /// Allowed max-failed-attempts options for the settings UI.
  static const maxFailedAttemptsOptions = [3, 5, 7, 10];

  /// Allowed base lockout options (seconds) for the settings UI.
  static const baseLockoutOptionsSeconds = [10, 30, 60, 120];

  final FlutterSecureStorage _storage;
  final PinHasher _hasher = const PinHasher();
  final LockoutPolicy _lockout = LockoutPolicy();
  bool _lockoutHydrated = false;
  Future<void> _verificationQueue = Future<void>.value();

  Duration _sessionGrace = defaultSessionGrace;
  bool _policyHydrated = false;

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

  /// Remaining lockout after too many wrong PINs; null if not locked.
  ///
  /// Call [ensureLockoutHydrated] first after cold start if reading before
  /// [verifyPin].
  Duration? get lockoutRemaining => _lockout.lockoutRemaining;

  bool get isLockedOut => _lockout.isLockedOut;

  void lockSession() {
    _unlockedUntil = null;
  }

  void unlockSession() {
    if (_sessionGrace == Duration.zero) {
      // Single-action mode: never stay unlocked across calls.
      _unlockedUntil = null;
      return;
    }
    _unlockedUntil = DateTime.now().add(_sessionGrace);
  }

  /// Current session grace duration (configurable via [setSessionGrace]).
  Duration get sessionGrace => _sessionGrace;

  /// Current max failed attempts before lockout (configurable via
  /// [setLockoutPolicy]).
  int get maxFailedAttempts => _lockout.maxFailedAttempts;

  /// Current base lockout duration (configurable via [setLockoutPolicy]).
  Duration get baseLockout => _lockout.baseLockout;

  /// Loads persisted lockout counters once (cold start).
  Future<void> ensureLockoutHydrated() => _hydrateLockout();

  /// Loads persisted security policy (session grace + lockout) once.
  /// Called automatically by [getSessionGrace] / [getLockoutPolicy] /
  /// [verifyPin] if not yet hydrated.
  Future<void> ensurePolicyHydrated() => _hydratePolicy();

  /// Returns the current session grace, hydrating from storage if needed.
  Future<Duration> getSessionGrace() async {
    await _hydratePolicy();
    return _sessionGrace;
  }

  /// Sets the session grace. Requires an unlocked sensitive session.
  /// Pass [Duration.zero] for single-action mode (re-prompt every time).
  Future<void> setSessionGrace(Duration d) async {
    if (!await isEnabled()) return;
    if (!isSessionUnlocked) {
      throw const BusinessRuleError(ruleAppLockRequired);
    }
    _sessionGrace = d;
    await _storage.write(key: _sessionGraceSecondsKey, value: '${d.inSeconds}');
  }

  /// Returns the current lockout policy, hydrating from storage if needed.
  Future<({int maxFailedAttempts, Duration baseLockout})>
  getLockoutPolicy() async {
    await _hydratePolicy();
    return (
      maxFailedAttempts: _lockout.maxFailedAttempts,
      baseLockout: _lockout.baseLockout,
    );
  }

  /// Sets the lockout policy. Requires an unlocked sensitive session.
  Future<void> setLockoutPolicy({
    int? maxFailedAttempts,
    Duration? baseLockout,
  }) async {
    if (!await isEnabled()) return;
    if (!isSessionUnlocked) {
      throw const BusinessRuleError(ruleAppLockRequired);
    }
    _lockout.updatePolicy(
      maxFailedAttempts: maxFailedAttempts,
      baseLockout: baseLockout,
    );
    if (maxFailedAttempts != null) {
      await _storage.write(
        key: _maxFailedAttemptsKey,
        value: '$maxFailedAttempts',
      );
    }
    if (baseLockout != null) {
      await _storage.write(
        key: _baseLockoutSecondsKey,
        value: '${baseLockout.inSeconds}',
      );
    }
  }

  /// Returns the timestamp the PIN was last set/changed, or null if no PIN.
  Future<DateTime?> pinSetAt() async {
    final raw = await _storage.read(key: _pinSetAtKey);
    if (raw == null || raw.isEmpty) return null;
    final ms = int.tryParse(raw);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Trivial PINs rejected by [setPin] / [changePin] (V092-B.6).
  static const trivialPinBlocklist = {
    '000000',
    '111111',
    '123456',
    '654321',
    '012345',
  };

  /// True when [pin] is in [trivialPinBlocklist] or is all identical digits.
  static bool isTrivialPin(String pin) {
    final trimmed = pin.trim();
    if (trivialPinBlocklist.contains(trimmed)) return true;
    if (trimmed.length >= minPinLength &&
        trimmed.runes.every((r) => r == trimmed.runes.first)) {
      return true;
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    final trimmed = pin.trim();
    if (trimmed.length < minPinLength) {
      throw StateError('PIN_TOO_SHORT');
    }
    if (isTrivialPin(trimmed)) {
      throw StateError('PIN_TOO_TRIVIAL');
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
    if (isTrivialPin(trimmed)) {
      throw StateError('PIN_TOO_TRIVIAL');
    }
    await _writePin(trimmed);
  }

  Future<void> _writePin(String trimmed) async {
    final salt = _hasher.randomSalt();
    final hash = _hasher.hashV2(trimmed, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _schemeKey, value: PinHasher.schemeV2);
    await _storage.write(key: _enabledKey, value: '1');
    await _storage.write(
      key: _pinSetAtKey,
      value: '${DateTime.now().millisecondsSinceEpoch}',
    );
    _lockout.reset();
    _lockoutHydrated = true;
    await _persistLockout();
    unlockSession();
  }

  /// Re-enables the lock without requiring a new PIN, when a PIN hash is
  /// already stored (e.g. the user disabled the lock but kept the PIN).
  ///
  /// Throws `PIN_NOT_SET` if no PIN hash exists — callers should use
  /// [setPin] in that case.
  /// Locks the session so the user must verify on the next sensitive action.
  Future<void> enable() async {
    if (!await hasPin()) {
      throw StateError('PIN_NOT_SET');
    }
    await _storage.write(key: _enabledKey, value: '1');
    _lockout.reset();
    _lockoutHydrated = true;
    await _persistLockout();
    lockSession();
  }

  /// Disables the lock but **keeps** the stored PIN hash so the user can
  /// re-enable via [enable] without setting a new PIN.
  ///
  /// To permanently delete the PIN, use [erasePin].
  Future<void> disable() async {
    await _storage.write(key: _enabledKey, value: '0');
    _lockout.reset();
    _lockoutHydrated = true;
    await _persistLockout();
    lockSession();
  }

  /// Permanently deletes the stored PIN hash, salt, scheme, and timestamp.
  /// Also disables the lock. Callers must verify the current PIN (via
  /// [ensureUnlocked] or [verifyPin]) before calling this — this method
  /// does not re-verify.
  Future<void> erasePin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _schemeKey);
    await _storage.delete(key: _pinSetAtKey);
    await _storage.write(key: _enabledKey, value: '0');
    _lockout.reset();
    _lockoutHydrated = true;
    await _persistLockout();
    lockSession();
  }

  /// Serializes verification attempts so lockout state cannot be raced by
  /// concurrent callers.
  Future<bool> verifyPin(String pin) {
    final result = Completer<bool>();
    final previous = _verificationQueue;
    _verificationQueue = previous.then<void>((_) async {
      try {
        result.complete(await _verifyPin(pin));
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  /// Verifies [pin]. Returns false on mismatch or active lockout.
  ///
  /// Throws [StateError] with message `PIN_LOCKED` when lockout is active
  /// (callers may inspect [lockoutRemaining]).
  Future<bool> _verifyPin(String pin) async {
    await _hydrateLockout();
    await _hydratePolicy();
    if (_lockout.isLockedOut) {
      throw StateError('PIN_LOCKED');
    }
    final String? salt;
    final String? expected;
    try {
      salt = await _storage.read(key: _pinSaltKey);
      expected = await _storage.read(key: _pinHashKey);
    } catch (e) {
      // PIN material unreadable — verification can never succeed; fail closed.
      AppLogger.warning(
        'AppLockService: PIN material read failed in _verifyPin',
        error: e,
      );
      return false;
    }
    if (salt == null || expected == null) return false;

    final scheme = await _storage.read(key: _schemeKey) ?? PinHasher.schemeV1;
    final ok = _hasher.verify(
      pin: pin,
      expectedHash: expected,
      salt: salt,
      scheme: scheme,
    );

    if (!ok) {
      _lockout.registerFailure();
      await _persistLockout();
      return false;
    }

    _lockout.reset();
    await _persistLockout();
    // Upgrade legacy hashes on successful unlock.
    if (scheme != PinHasher.schemeV2) {
      await _writePin(pin.trim());
    } else {
      unlockSession();
    }
    return true;
  }

  /// Returns true if action may proceed (lock off, or session valid, or PIN ok).
  Future<bool> ensureUnlocked({String? pin}) async {
    try {
      if (!await isEnabled()) return true;
    } catch (e) {
      // Secure storage unreadable (e.g. Keystore error) — fail closed.
      AppLogger.warning(
        'AppLockService: isEnabled read failed in ensureUnlocked',
        error: e,
      );
      return false;
    }
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
    try {
      if (!await isEnabled()) return;
    } catch (e) {
      // Secure storage unreadable (e.g. Keystore error) — fail closed and
      // surface the standard lock gate instead of a raw platform exception.
      AppLogger.warning(
        'AppLockService: isEnabled read failed in requireSensitiveSession',
        error: e,
      );
      throw const BusinessRuleError(ruleAppLockRequired);
    }
    if (isSessionUnlocked) return;
    throw const BusinessRuleError(ruleAppLockRequired);
  }

  Future<void> _hydrateLockout() async {
    if (_lockoutHydrated) return;
    _lockoutHydrated = true;
    final String? attemptsRaw;
    final String? untilRaw;
    try {
      attemptsRaw = await _storage.read(key: _failedAttemptsKey);
      untilRaw = await _storage.read(key: _lockedUntilKey);
    } catch (e) {
      // Unreadable counters — proceed with defaults; PIN verification has its
      // own fail-closed guard, so this cannot open the gate.
      AppLogger.warning(
        'AppLockService: lockout state read failed; using defaults',
        error: e,
      );
      return;
    }
    final failedAttempts = int.tryParse(attemptsRaw ?? '') ?? 0;
    final lockedUntilMs = int.tryParse(untilRaw ?? '');
    _lockout.fromSnapshot(
      LockoutSnapshot(
        failedAttempts: failedAttempts,
        lockedUntilMs: lockedUntilMs,
      ),
    );
    // If the lockout was expired, persist the cleared state.
    if (failedAttempts != 0 && !_lockout.isLockedOut) {
      await _persistLockout();
    }
  }

  Future<void> _persistLockout() async {
    final snapshot = _lockout.toSnapshot();
    if (snapshot.failedAttempts <= 0 && snapshot.lockedUntilMs == null) {
      await _storage.delete(key: _failedAttemptsKey);
      await _storage.delete(key: _lockedUntilKey);
      return;
    }
    await _storage.write(
      key: _failedAttemptsKey,
      value: '${snapshot.failedAttempts}',
    );
    if (snapshot.lockedUntilMs == null) {
      await _storage.delete(key: _lockedUntilKey);
    } else {
      await _storage.write(
        key: _lockedUntilKey,
        value: '${snapshot.lockedUntilMs}',
      );
    }
  }

  Future<void> _hydratePolicy() async {
    if (_policyHydrated) return;
    _policyHydrated = true;
    final String? graceRaw;
    final String? maxRaw;
    final String? lockRaw;
    try {
      graceRaw = await _storage.read(key: _sessionGraceSecondsKey);
      maxRaw = await _storage.read(key: _maxFailedAttemptsKey);
      lockRaw = await _storage.read(key: _baseLockoutSecondsKey);
    } catch (e) {
      // Unreadable policy — keep in-memory defaults; gates stay fail-closed.
      AppLogger.warning(
        'AppLockService: policy read failed; using defaults',
        error: e,
      );
      return;
    }
    if (graceRaw != null && graceRaw.isNotEmpty) {
      final s = int.tryParse(graceRaw);
      if (s != null && s >= 0 && s <= 600) {
        _sessionGrace = Duration(seconds: s);
      }
    }
    if (maxRaw != null && maxRaw.isNotEmpty) {
      final n = int.tryParse(maxRaw);
      if (n != null && n >= 3 && n <= 10) {
        _lockout.updatePolicy(maxFailedAttempts: n);
      }
    }
    if (lockRaw != null && lockRaw.isNotEmpty) {
      final s = int.tryParse(lockRaw);
      if (s != null && s >= 10 && s <= 300) {
        _lockout.updatePolicy(baseLockout: Duration(seconds: s));
      }
    }
  }
}
