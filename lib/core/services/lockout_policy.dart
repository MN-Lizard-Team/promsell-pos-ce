/// Brute-force lockout policy for [AppLockService].
///
/// Tracks failed PIN attempts and enforces an exponential backoff lockout
/// after [maxFailedAttempts] is reached. State is held in memory; the caller
/// is responsible for persisting/restoring via [toSnapshot] / [fromSnapshot].
class LockoutPolicy {
  LockoutPolicy({
    int maxFailedAttempts = defaultMaxFailedAttempts,
    Duration baseLockout = defaultBaseLockout,
  }) : _maxFailedAttempts = maxFailedAttempts,
       _baseLockout = baseLockout;

  /// Default failed attempts before temporary lockout.
  static const defaultMaxFailedAttempts = 5;

  /// Default initial lockout; doubles each subsequent fail.
  static const defaultBaseLockout = Duration(seconds: 30);

  int _maxFailedAttempts;
  Duration _baseLockout;

  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  /// Current max failed attempts before lockout.
  int get maxFailedAttempts => _maxFailedAttempts;

  /// Current base lockout duration.
  Duration get baseLockout => _baseLockout;

  /// Remaining lockout after too many wrong PINs; null if not locked.
  Duration? get lockoutRemaining {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(DateTime.now());
    if (left.isNegative) {
      _lockedUntil = null;
      _failedAttempts = 0;
      return null;
    }
    return left;
  }

  bool get isLockedOut => lockoutRemaining != null;

  /// Records a failed attempt and activates lockout if threshold is reached.
  void registerFailure() {
    _failedAttempts++;
    if (_failedAttempts >= _maxFailedAttempts) {
      final multiplier =
          1 << (_failedAttempts - _maxFailedAttempts).clamp(0, 4);
      _lockedUntil = DateTime.now().add(
        Duration(seconds: _baseLockout.inSeconds * multiplier),
      );
    }
  }

  /// Resets failed attempts and clears lockout (on successful verify).
  void reset() {
    _failedAttempts = 0;
    _lockedUntil = null;
  }

  /// Updates the configurable policy parameters.
  void updatePolicy({int? maxFailedAttempts, Duration? baseLockout}) {
    if (maxFailedAttempts != null) {
      if (maxFailedAttempts < 3 || maxFailedAttempts > 10) {
        throw StateError('LOCKOUT_POLICY_OUT_OF_RANGE');
      }
      _maxFailedAttempts = maxFailedAttempts;
    }
    if (baseLockout != null) {
      if (baseLockout.inSeconds < 10 || baseLockout.inSeconds > 300) {
        throw StateError('LOCKOUT_POLICY_OUT_OF_RANGE');
      }
      _baseLockout = baseLockout;
    }
  }

  /// Snapshot for persistence.
  LockoutSnapshot toSnapshot() => LockoutSnapshot(
    failedAttempts: _failedAttempts,
    lockedUntilMs: _lockedUntil?.millisecondsSinceEpoch,
  );

  /// Restores from a persisted snapshot. Clears expired lockouts.
  void fromSnapshot(LockoutSnapshot snapshot) {
    _failedAttempts = snapshot.failedAttempts;
    if (snapshot.lockedUntilMs != null) {
      final until = DateTime.fromMillisecondsSinceEpoch(
        snapshot.lockedUntilMs!,
      );
      if (until.isAfter(DateTime.now())) {
        _lockedUntil = until;
      } else {
        _lockedUntil = null;
        _failedAttempts = 0;
      }
    } else {
      _lockedUntil = null;
    }
  }
}

/// Persisted lockout state.
class LockoutSnapshot {
  const LockoutSnapshot({
    required this.failedAttempts,
    required this.lockedUntilMs,
  });

  final int failedAttempts;
  final int? lockedUntilMs;
}
