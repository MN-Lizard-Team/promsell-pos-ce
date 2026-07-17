import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Best-effort screen capture / recents-preview protection (Android FLAG_SECURE).
///
/// No-op on platforms without a channel implementation. Failures are swallowed
/// so sensitive UI still works if the native side is unavailable.
abstract final class SecureScreen {
  SecureScreen._();

  static const _channel = MethodChannel('promsell/secure_screen');

  static Future<void> setSecure(bool enable) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('setSecure', {'enable': enable});
    } catch (_) {
      // Desktop / missing plugin — ignore.
    }
  }
}
