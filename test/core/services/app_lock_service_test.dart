import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late Map<String, String> map;
  late AppLockService lock;

  setUp(() {
    storage = _MockStorage();
    map = {};
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
      final key = inv.namedArguments[#key] as String;
      return map[key];
    });
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((inv) async {
      final key = inv.namedArguments[#key] as String;
      final value = inv.namedArguments[#value] as String;
      map[key] = value;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((inv) async {
      final key = inv.namedArguments[#key] as String;
      map.remove(key);
    });
    lock = AppLockService(storage: storage);
  });

  test('minPinLength is 6 and enforced', () async {
    expect(AppLockService.minPinLength, 6);
    expect(() => lock.setPin('12345'), throwsA(isA<StateError>()));
    await lock.setPin('147258');
    expect(await lock.isEnabled(), isTrue);
    expect(await lock.hasPin(), isTrue);
  });

  test('session unlock grace', () {
    expect(lock.isSessionUnlocked, isFalse);
    lock.unlockSession();
    expect(lock.isSessionUnlocked, isTrue);
    lock.lockSession();
    expect(lock.isSessionUnlocked, isFalse);
  });

  test('requireSensitiveSession allows when lock disabled', () async {
    await lock.requireSensitiveSession();
  });

  test(
    'requireSensitiveSession throws when lock on and session cold',
    () async {
      await lock.setPin('147258');
      lock.lockSession();
      await expectLater(
        () => lock.requireSensitiveSession(),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            AppLockService.ruleAppLockRequired,
          ),
        ),
      );
      lock.unlockSession();
      await lock.requireSensitiveSession();
    },
  );

  test('verifyPin success and wrong pin', () async {
    await lock.setPin('246810');
    lock.lockSession();
    expect(await lock.verifyPin('081234'), isFalse);
    expect(await lock.verifyPin('246810'), isTrue);
    expect(lock.isSessionUnlocked, isTrue);
  });

  test('serializes concurrent verification attempts for lockout', () async {
    await lock.setPin('135790');
    lock.lockSession();

    final results = await Future.wait([
      for (var i = 0; i < lock.maxFailedAttempts; i++) lock.verifyPin('081234'),
    ]);

    expect(results, everyElement(isFalse));
    expect(lock.isLockedOut, isTrue);
  });

  test('ensureUnlocked respects disabled and session', () async {
    expect(await lock.ensureUnlocked(), isTrue); // lock off
    await lock.setPin('135790');
    lock.lockSession();
    expect(await lock.ensureUnlocked(), isFalse);
    expect(await lock.ensureUnlocked(pin: '135790'), isTrue);
    expect(await lock.ensureUnlocked(), isTrue); // session grace
  });

  test('lockout after max failed attempts', () async {
    await lock.setPin('147258');
    lock.lockSession();
    for (var i = 0; i < lock.maxFailedAttempts; i++) {
      expect(await lock.verifyPin('081234'), isFalse);
    }
    expect(lock.isLockedOut, isTrue);
    expect(
      () => lock.verifyPin('147258'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_LOCKED')),
    );
    // Persisted for cold start
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isTrue);
    expect(map.containsKey('promsell_app_lock_locked_until_ms_v1'), isTrue);
  });

  test('lockout survives new AppLockService (cold start)', () async {
    await lock.setPin('147258');
    lock.lockSession();
    for (var i = 0; i < lock.maxFailedAttempts; i++) {
      expect(await lock.verifyPin('081234'), isFalse);
    }
    expect(lock.isLockedOut, isTrue);

    final restarted = AppLockService(storage: storage);
    await restarted.ensureLockoutHydrated();
    expect(restarted.isLockedOut, isTrue);
    expect(
      () => restarted.verifyPin('147258'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_LOCKED')),
    );
  });

  test('success clears persisted lockout keys', () async {
    await lock.setPin('246810');
    lock.lockSession();
    for (var i = 0; i < lock.maxFailedAttempts - 1; i++) {
      expect(await lock.verifyPin('081234'), isFalse);
    }
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isTrue);
    expect(await lock.verifyPin('246810'), isTrue);
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isFalse);
    expect(map.containsKey('promsell_app_lock_locked_until_ms_v1'), isFalse);
  });

  test('disable keeps PIN hash but turns off enabled flag', () async {
    await lock.setPin('135790');
    lock.lockSession();
    for (var i = 0; i < lock.maxFailedAttempts; i++) {
      expect(await lock.verifyPin('081234'), isFalse);
    }
    await lock.disable();
    expect(await lock.isEnabled(), isFalse);
    // V092-B: disable keeps the PIN hash so re-enable does not require a new PIN.
    expect(await lock.hasPin(), isTrue);
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isFalse);
    expect(map.containsKey('promsell_app_lock_locked_until_ms_v1'), isFalse);
  });

  test('expired lockout is cleared on hydrate', () async {
    await lock.setPin('147258');
    map['promsell_app_lock_failed_attempts_v1'] = '5';
    map['promsell_app_lock_locked_until_ms_v1'] =
        '${DateTime.now().subtract(const Duration(seconds: 5)).millisecondsSinceEpoch}';

    final restarted = AppLockService(storage: storage);
    await restarted.ensureLockoutHydrated();
    expect(restarted.isLockedOut, isFalse);
    restarted.lockSession();
    expect(await restarted.verifyPin('147258'), isTrue);
  });

  test('setPin refuses to overwrite existing PIN', () async {
    await lock.setPin('147258');
    expect(
      () => lock.setPin('246810'),
      throwsA(
        isA<StateError>().having((e) => e.message, 'm', 'PIN_ALREADY_SET'),
      ),
    );
    // Original PIN still works.
    expect(await lock.verifyPin('147258'), isTrue);
  });

  test('changePin requires correct current PIN', () async {
    await lock.setPin('147258');
    lock.lockSession();
    expect(
      () => lock.changePin(currentPin: '081234', newPin: '135790'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_WRONG')),
    );
  });

  test('changePin updates to new PIN after verifying current', () async {
    await lock.setPin('147258');
    lock.lockSession();
    await lock.changePin(currentPin: '147258', newPin: '246810');
    // Old PIN no longer works.
    lock.lockSession();
    expect(await lock.verifyPin('147258'), isFalse);
    // New PIN works.
    expect(await lock.verifyPin('246810'), isTrue);
  });

  test('changePin enforces min length on new PIN', () async {
    await lock.setPin('147258');
    lock.lockSession();
    expect(
      () => lock.changePin(currentPin: '147258', newPin: '123'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_TOO_SHORT')),
    );
  });

  // V092-B.6 regression: trivial PINs are rejected.
  group('trivial PIN blocklist (V092-B.6)', () {
    test('isTrivialPin flags blocklist entries', () {
      expect(AppLockService.isTrivialPin('000000'), isTrue);
      expect(AppLockService.isTrivialPin('111111'), isTrue);
      expect(AppLockService.isTrivialPin('123456'), isTrue);
      expect(AppLockService.isTrivialPin('654321'), isTrue);
      expect(AppLockService.isTrivialPin('012345'), isTrue);
    });

    test('isTrivialPin flags all-identical digits', () {
      expect(AppLockService.isTrivialPin('222222'), isTrue);
      expect(AppLockService.isTrivialPin('999999'), isTrue);
      expect(AppLockService.isTrivialPin('888888'), isTrue);
    });

    test('isTrivialPin accepts non-trivial PINs', () {
      expect(AppLockService.isTrivialPin('147258'), isFalse);
      expect(AppLockService.isTrivialPin('246810'), isFalse);
      expect(AppLockService.isTrivialPin('135790'), isFalse);
    });

    test('setPin rejects trivial PINs with PIN_TOO_TRIVIAL', () {
      expect(
        () => lock.setPin('123456'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'm', 'PIN_TOO_TRIVIAL'),
        ),
      );
      expect(
        () => lock.setPin('000000'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'm', 'PIN_TOO_TRIVIAL'),
        ),
      );
      expect(
        () => lock.setPin('999999'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'm', 'PIN_TOO_TRIVIAL'),
        ),
      );
    });

    test('changePin rejects trivial new PIN', () async {
      await lock.setPin('147258');
      lock.lockSession();
      expect(
        () => lock.changePin(currentPin: '147258', newPin: '123456'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'm', 'PIN_TOO_TRIVIAL'),
        ),
      );
    });
  });

  group('configurable session grace', () {
    test('defaults to 2 minutes', () async {
      final grace = await lock.getSessionGrace();
      expect(grace, AppLockService.defaultSessionGrace);
    });

    test('setSessionGrace requires unlocked session', () async {
      await lock.setPin('147258');
      lock.lockSession();
      await expectLater(
        () => lock.setSessionGrace(const Duration(seconds: 30)),
        throwsA(isA<BusinessRuleError>()),
      );
    });

    test('setSessionGrace updates and persists', () async {
      await lock.setPin('147258');
      // setPin unlocks the session
      expect(lock.isSessionUnlocked, isTrue);
      await lock.setSessionGrace(const Duration(seconds: 30));
      expect(lock.sessionGrace, const Duration(seconds: 30));
      // New instance reads persisted value
      final lock2 = AppLockService(storage: storage);
      final grace = await lock2.getSessionGrace();
      expect(grace, const Duration(seconds: 30));
    });

    test('setSessionGrace zero enables single-action mode', () async {
      await lock.setPin('147258');
      await lock.setSessionGrace(Duration.zero);
      expect(lock.sessionGrace, Duration.zero);
      lock.unlockSession();
      // With zero grace, session should not stay unlocked
      expect(lock.isSessionUnlocked, isFalse);
    });

    test('setSessionGrace is no-op when PIN disabled', () async {
      // No PIN set → isEnabled() false → setSessionGrace returns silently
      await lock.setSessionGrace(const Duration(seconds: 60));
      // No throw, no change to default
      expect(lock.sessionGrace, AppLockService.defaultSessionGrace);
    });
  });

  group('configurable lockout policy', () {
    test('defaults to 5 attempts / 30s', () async {
      final policy = await lock.getLockoutPolicy();
      expect(policy.maxFailedAttempts, 5);
      expect(policy.baseLockout, const Duration(seconds: 30));
    });

    test('setLockoutPolicy requires unlocked session', () async {
      await lock.setPin('147258');
      lock.lockSession();
      await expectLater(
        () => lock.setLockoutPolicy(maxFailedAttempts: 3),
        throwsA(isA<BusinessRuleError>()),
      );
    });

    test('setLockoutPolicy updates maxFailedAttempts', () async {
      await lock.setPin('147258');
      expect(lock.isSessionUnlocked, isTrue);
      await lock.setLockoutPolicy(maxFailedAttempts: 3);
      expect(lock.maxFailedAttempts, 3);
      // New instance reads persisted value
      final lock2 = AppLockService(storage: storage);
      final policy = await lock2.getLockoutPolicy();
      expect(policy.maxFailedAttempts, 3);
    });

    test('setLockoutPolicy updates baseLockout', () async {
      await lock.setPin('147258');
      await lock.setLockoutPolicy(baseLockout: const Duration(seconds: 60));
      expect(lock.baseLockout, const Duration(seconds: 60));
      final lock2 = AppLockService(storage: storage);
      final policy = await lock2.getLockoutPolicy();
      expect(policy.baseLockout, const Duration(seconds: 60));
    });

    test('setLockoutPolicy rejects out-of-range maxAttempts', () async {
      await lock.setPin('147258');
      expect(
        () => lock.setLockoutPolicy(maxFailedAttempts: 2),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'm',
            'LOCKOUT_POLICY_OUT_OF_RANGE',
          ),
        ),
      );
      expect(
        () => lock.setLockoutPolicy(maxFailedAttempts: 11),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'm',
            'LOCKOUT_POLICY_OUT_OF_RANGE',
          ),
        ),
      );
    });

    test('setLockoutPolicy rejects out-of-range baseLockout', () async {
      await lock.setPin('147258');
      expect(
        () => lock.setLockoutPolicy(baseLockout: const Duration(seconds: 5)),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'm',
            'LOCKOUT_POLICY_OUT_OF_RANGE',
          ),
        ),
      );
      expect(
        () => lock.setLockoutPolicy(baseLockout: const Duration(seconds: 301)),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'm',
            'LOCKOUT_POLICY_OUT_OF_RANGE',
          ),
        ),
      );
    });

    test('custom lockout policy is enforced on wrong PIN', () async {
      await lock.setPin('147258');
      await lock.setLockoutPolicy(maxFailedAttempts: 3);
      await lock.setSessionGrace(Duration.zero);
      lock.lockSession();
      // 3 wrong attempts should trigger lockout
      for (var i = 0; i < 3; i++) {
        await lock.verifyPin('000000');
      }
      expect(lock.isLockedOut, isTrue);
      // 4th attempt throws PIN_LOCKED
      await expectLater(
        () => lock.verifyPin('147258'),
        throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_LOCKED')),
      );
    });
  });

  group('pinSetAt timestamp', () {
    test('null before PIN is set', () async {
      expect(await lock.pinSetAt(), isNull);
    });

    test('set after setPin', () async {
      await lock.setPin('147258');
      final ts = await lock.pinSetAt();
      expect(ts, isNotNull);
      expect(ts!.isBefore(DateTime.now()) || ts == DateTime.now(), isTrue);
    });

    test('updated after changePin', () async {
      await lock.setPin('147258');
      final ts1 = await lock.pinSetAt();
      await Future.delayed(const Duration(milliseconds: 10));
      await lock.changePin(currentPin: '147258', newPin: '246810');
      final ts2 = await lock.pinSetAt();
      expect(ts2!.isAfter(ts1!), isTrue);
    });

    test('kept after disable, cleared after erasePin', () async {
      await lock.setPin('147258');
      expect(await lock.pinSetAt(), isNotNull);
      await lock.disable();
      // disable keeps pinSetAt
      expect(await lock.pinSetAt(), isNotNull);
      await lock.erasePin();
      expect(await lock.pinSetAt(), isNull);
    });
  });

  group('enable / disable / erasePin', () {
    test('enable throws PIN_NOT_SET when no PIN stored', () async {
      expect(
        () => lock.enable(),
        throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_NOT_SET')),
      );
    });

    test('disable then enable re-enables without new PIN', () async {
      await lock.setPin('147258');
      expect(await lock.isEnabled(), isTrue);
      expect(await lock.hasPin(), isTrue);

      await lock.disable();
      expect(await lock.isEnabled(), isFalse);
      expect(await lock.hasPin(), isTrue); // PIN kept

      await lock.enable();
      expect(await lock.isEnabled(), isTrue);
      expect(await lock.hasPin(), isTrue);
    });

    test('enable locks session (must verify on next action)', () async {
      await lock.setPin('147258');
      lock.unlockSession();
      expect(lock.isSessionUnlocked, isTrue);

      await lock.disable();
      await lock.enable();
      expect(lock.isSessionUnlocked, isFalse);
    });

    test('erasePin deletes hash + salt + scheme + pinSetAt', () async {
      await lock.setPin('147258');
      expect(await lock.hasPin(), isTrue);
      expect(map.containsKey('promsell_app_lock_pin_hash_v1'), isTrue);
      expect(map.containsKey('promsell_app_lock_pin_salt_v1'), isTrue);
      expect(map.containsKey('promsell_app_lock_pin_scheme_v1'), isTrue);

      await lock.erasePin();
      expect(await lock.isEnabled(), isFalse);
      expect(await lock.hasPin(), isFalse);
      expect(map.containsKey('promsell_app_lock_pin_hash_v1'), isFalse);
      expect(map.containsKey('promsell_app_lock_pin_salt_v1'), isFalse);
      expect(map.containsKey('promsell_app_lock_pin_scheme_v1'), isFalse);
    });

    test('erasePin locks session', () async {
      await lock.setPin('147258');
      lock.unlockSession();
      expect(lock.isSessionUnlocked, isTrue);

      await lock.erasePin();
      expect(lock.isSessionUnlocked, isFalse);
    });

    test('after erasePin, enable throws PIN_NOT_SET', () async {
      await lock.setPin('147258');
      await lock.erasePin();
      expect(
        () => lock.enable(),
        throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_NOT_SET')),
      );
    });

    test('after erasePin, setPin works (new PIN)', () async {
      await lock.setPin('147258');
      await lock.erasePin();
      // setPin should work because no PIN exists
      await lock.setPin('246810');
      expect(await lock.hasPin(), isTrue);
      expect(await lock.isEnabled(), isTrue);
    });

    test('disable clears lockout counters', () async {
      await lock.setPin('147258');
      lock.lockSession();
      for (var i = 0; i < lock.maxFailedAttempts; i++) {
        await lock.verifyPin('081234');
      }
      expect(lock.isLockedOut, isTrue);

      await lock.disable();
      expect(lock.isLockedOut, isFalse);
      expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isFalse);
    });

    test('erasePin clears lockout counters', () async {
      await lock.setPin('147258');
      lock.lockSession();
      for (var i = 0; i < lock.maxFailedAttempts; i++) {
        await lock.verifyPin('081234');
      }
      expect(lock.isLockedOut, isTrue);

      await lock.erasePin();
      expect(lock.isLockedOut, isFalse);
      expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isFalse);
    });
  });
}
