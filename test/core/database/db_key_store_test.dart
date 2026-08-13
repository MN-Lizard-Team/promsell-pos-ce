import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/db_key_store.dart';

/// POST-090 B5: desktop-debug key policy (production Android/iOS uses secure storage).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('desktop debug path uses fixed all-zero 64-hex key', () async {
    // flutter_test defaults to Android; force desktop so DbKeyStore skips plugin.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    expect(kDebugMode, isTrue, reason: 'unit tests run in debug');
    final key = await DbKeyStore.getOrCreateKey();
    expect(key.length, 64);
    expect(RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(key), isTrue);
    expect(
      key,
      '0' * 64,
      reason:
          'Dev desktop must use fixed key; never random without secure storage',
    );

    // Stable across calls in the same process.
    expect(await DbKeyStore.getOrCreateKey(), key);
  });
}
