import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// In-memory secure storage backed [AppLockService] (lock disabled by default).
AppLockService fakeAppLock({Map<String, String>? seed}) {
  final map = seed ?? <String, String>{};
  final storage = MockSecureStorage();
  when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
    return map[inv.namedArguments[#key] as String];
  });
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((inv) async {
    map[inv.namedArguments[#key] as String] =
        inv.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key'))).thenAnswer((inv) async {
    map.remove(inv.namedArguments[#key] as String);
  });
  return AppLockService(storage: storage);
}
