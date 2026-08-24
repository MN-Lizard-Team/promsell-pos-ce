import 'package:flutter/foundation.dart';

/// Lightweight logging utility for Promsell POS CE.
///
/// Every log call is guarded by [kDebugMode], so release builds produce no
/// output at all. This guard is required because [debugPrint] is only
/// *throttled* in release builds — it is not stripped — so relying on it
/// alone would still print logs in production.
///
/// For production telemetry (Crashlytics/Sentry), replace the body of
/// [error] with your crash reporter.
class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (!kDebugMode) return;
    debugPrint('[INFO] $message');
  }

  static void warning(String message, {Object? error, StackTrace? stack}) {
    if (!kDebugMode) return;
    debugPrint('[WARN] $message');
    if (error != null) debugPrint('  error: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }

  static void error(String message, {Object? error, StackTrace? stack}) {
    if (!kDebugMode) return;
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  error: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }
}
