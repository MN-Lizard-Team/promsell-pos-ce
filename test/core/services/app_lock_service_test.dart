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
    await lock.setPin('123456');
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
      await lock.setPin('123456');
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
    await lock.setPin('654321');
    lock.lockSession();
    expect(await lock.verifyPin('000000'), isFalse);
    expect(await lock.verifyPin('654321'), isTrue);
    expect(lock.isSessionUnlocked, isTrue);
  });

  test('ensureUnlocked respects disabled and session', () async {
    expect(await lock.ensureUnlocked(), isTrue); // lock off
    await lock.setPin('111111');
    lock.lockSession();
    expect(await lock.ensureUnlocked(), isFalse);
    expect(await lock.ensureUnlocked(pin: '111111'), isTrue);
    expect(await lock.ensureUnlocked(), isTrue); // session grace
  });

  test('lockout after max failed attempts', () async {
    await lock.setPin('999999');
    lock.lockSession();
    for (var i = 0; i < AppLockService.maxFailedAttempts; i++) {
      expect(await lock.verifyPin('000000'), isFalse);
    }
    expect(lock.isLockedOut, isTrue);
    expect(
      () => lock.verifyPin('999999'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_LOCKED')),
    );
    // Persisted for cold start
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isTrue);
    expect(map.containsKey('promsell_app_lock_locked_until_ms_v1'), isTrue);
  });

  test('lockout survives new AppLockService (cold start)', () async {
    await lock.setPin('999999');
    lock.lockSession();
    for (var i = 0; i < AppLockService.maxFailedAttempts; i++) {
      expect(await lock.verifyPin('000000'), isFalse);
    }
    expect(lock.isLockedOut, isTrue);

    final restarted = AppLockService(storage: storage);
    await restarted.ensureLockoutHydrated();
    expect(restarted.isLockedOut, isTrue);
    expect(
      () => restarted.verifyPin('999999'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_LOCKED')),
    );
  });

  test('success clears persisted lockout keys', () async {
    await lock.setPin('888888');
    lock.lockSession();
    for (var i = 0; i < AppLockService.maxFailedAttempts - 1; i++) {
      expect(await lock.verifyPin('000000'), isFalse);
    }
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isTrue);
    expect(await lock.verifyPin('888888'), isTrue);
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isFalse);
    expect(map.containsKey('promsell_app_lock_locked_until_ms_v1'), isFalse);
  });

  test('disable clears pin and lockout keys', () async {
    await lock.setPin('121212');
    lock.lockSession();
    for (var i = 0; i < AppLockService.maxFailedAttempts; i++) {
      expect(await lock.verifyPin('000000'), isFalse);
    }
    await lock.disable();
    expect(await lock.isEnabled(), isFalse);
    expect(await lock.hasPin(), isFalse);
    expect(map.containsKey('promsell_app_lock_failed_attempts_v1'), isFalse);
    expect(map.containsKey('promsell_app_lock_locked_until_ms_v1'), isFalse);
  });

  test('expired lockout is cleared on hydrate', () async {
    await lock.setPin('555555');
    map['promsell_app_lock_failed_attempts_v1'] = '5';
    map['promsell_app_lock_locked_until_ms_v1'] =
        '${DateTime.now().subtract(const Duration(seconds: 5)).millisecondsSinceEpoch}';

    final restarted = AppLockService(storage: storage);
    await restarted.ensureLockoutHydrated();
    expect(restarted.isLockedOut, isFalse);
    restarted.lockSession();
    expect(await restarted.verifyPin('555555'), isTrue);
  });

  test('setPin refuses to overwrite existing PIN', () async {
    await lock.setPin('123456');
    expect(
      () => lock.setPin('654321'),
      throwsA(
        isA<StateError>().having((e) => e.message, 'm', 'PIN_ALREADY_SET'),
      ),
    );
    // Original PIN still works.
    expect(await lock.verifyPin('123456'), isTrue);
  });

  test('changePin requires correct current PIN', () async {
    await lock.setPin('123456');
    lock.lockSession();
    expect(
      () => lock.changePin(currentPin: '000000', newPin: '999999'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_WRONG')),
    );
  });

  test('changePin updates to new PIN after verifying current', () async {
    await lock.setPin('123456');
    lock.lockSession();
    await lock.changePin(currentPin: '123456', newPin: '999999');
    // Old PIN no longer works.
    lock.lockSession();
    expect(await lock.verifyPin('123456'), isFalse);
    // New PIN works.
    expect(await lock.verifyPin('999999'), isTrue);
  });

  test('changePin enforces min length on new PIN', () async {
    await lock.setPin('123456');
    lock.lockSession();
    expect(
      () => lock.changePin(currentPin: '123456', newPin: '123'),
      throwsA(isA<StateError>().having((e) => e.message, 'm', 'PIN_TOO_SHORT')),
    );
  });
}
