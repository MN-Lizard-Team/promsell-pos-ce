import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_lifecycle_observer.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockStorage storage;
  late Map<String, String> map;
  late AppLockService lock;
  late AppLockLifecycleObserver observer;

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
    observer = AppLockLifecycleObserver(lock);
  });

  tearDown(() {
    observer.stop();
  });

  group('AppLockLifecycleObserver (V092-B.2)', () {
    test('start() locks session when PIN is enabled', () async {
      await lock.setPin('147258');
      lock.unlockSession();
      expect(lock.isSessionUnlocked, isTrue);

      await observer.start();

      expect(lock.isSessionUnlocked, isFalse);
    });

    test('start() is a no-op when PIN is disabled', () async {
      // No PIN set → isEnabled() returns false.
      await observer.start();
      expect(lock.isSessionUnlocked, isFalse);
    });

    test('didChangeAppLifecycleState paused locks session', () async {
      await lock.setPin('147258');
      lock.unlockSession();
      expect(lock.isSessionUnlocked, isTrue);

      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(lock.isSessionUnlocked, isFalse);
    });

    test('didChangeAppLifecycleState hidden locks session', () async {
      await lock.setPin('147258');
      lock.unlockSession();

      observer.didChangeAppLifecycleState(AppLifecycleState.hidden);

      expect(lock.isSessionUnlocked, isFalse);
    });

    test('didChangeAppLifecycleState detached locks session', () async {
      await lock.setPin('147258');
      lock.unlockSession();

      observer.didChangeAppLifecycleState(AppLifecycleState.detached);

      expect(lock.isSessionUnlocked, isFalse);
    });

    test('didChangeAppLifecycleState resumed does NOT auto-unlock', () async {
      await lock.setPin('147258');
      lock.lockSession();
      expect(lock.isSessionUnlocked, isFalse);

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Resume must not unlock — user must enter PIN again.
      expect(lock.isSessionUnlocked, isFalse);
    });

    test(
      'didChangeAppLifecycleState inactive does NOT lock (transient)',
      () async {
        await lock.setPin('147258');
        lock.unlockSession();

        // inactive fires on transient interruptions (e.g. notification shade);
        // locking here would force PIN re-entry too aggressively.
        observer.didChangeAppLifecycleState(AppLifecycleState.inactive);

        expect(lock.isSessionUnlocked, isTrue);
      },
    );
  });
}
