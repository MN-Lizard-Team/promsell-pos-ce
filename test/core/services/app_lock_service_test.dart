import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';

void main() {
  // Uses real FlutterSecureStorage — may be no-op/mock on pure unit VM.
  // These tests cover hash/session logic when storage works; skip if platform channel missing.

  test('minPinLength enforced', () async {
    final lock = AppLockService();
    expect(() => lock.setPin('12'), throwsA(isA<StateError>()));
  });

  test('session unlock grace', () {
    final lock = AppLockService();
    expect(lock.isSessionUnlocked, isFalse);
    lock.unlockSession();
    expect(lock.isSessionUnlocked, isTrue);
    lock.lockSession();
    expect(lock.isSessionUnlocked, isFalse);
  });
}
