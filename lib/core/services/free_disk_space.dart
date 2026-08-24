import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Queries free disk space through the platform channel hosted by
/// MainActivity (shared with the secure-screen handler).
///
/// Mirrors [SecureScreen]'s degrade-gracefully contract: every failure mode
/// (Windows desktop without a native handler, stale iOS build, invalid path)
/// resolves to -1 instead of throwing, so callers treat -1 as "unknown".
@LazySingleton()
class FreeDiskSpaceService {
  const FreeDiskSpaceService();

  static const _channel = MethodChannel('promsell/secure_screen');

  /// Returns available free space at [path] in bytes, or -1 if unknown.
  Future<int> getFreeDiskSpace(String path) async {
    if (kIsWeb) return -1;
    try {
      final bytes = await _channel.invokeMethod<int>('getFreeDiskSpace', {
        'path': path,
      });
      return bytes ?? -1;
    } on PlatformException {
      return -1;
    } on MissingPluginException {
      return -1;
    }
  }
}
