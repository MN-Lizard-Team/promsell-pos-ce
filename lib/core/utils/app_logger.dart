import 'package:flutter/foundation.dart';

/// Lightweight logging utility for Promsell POS CE.
///
/// Uses [debugPrint] under the hood so logs are stripped in release builds
/// by default. For production telemetry (Crashlytics/Sentry), replace the
/// body of [error] with your crash reporter.
class AppLogger {
  AppLogger._();

  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void warning(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[WARN] $message');
    if (error != null) debugPrint('  error: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }

  static void error(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  error: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }
}
