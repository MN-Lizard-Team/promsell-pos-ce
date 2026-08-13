import 'package:injectable/injectable.dart';

/// Generates human-readable internal SKUs: `{PREFIX}{#####}`.
///
/// Default: `SKU00001`. Prefix is alphanumeric (A–Z, 0–9); counter wraps at 100000.
@injectable
class SkuGenerator {
  SkuGenerator();

  static const String defaultPrefix = 'SKU';

  int _counter = 0;

  /// Initializes the internal counter from a persisted value.
  void initCounter(int value) {
    _counter = value % 100000;
  }

  /// Current counter — persist after each generate.
  int get currentCounter => _counter;

  /// Generates the next SKU.
  ///
  /// [prefix] is normalized to uppercase A–Z/0–9; blank/invalid → [defaultPrefix].
  String generate({String? prefix}) {
    final p = normalizePrefix(prefix);
    _incrementCounter();
    final seq = (_counter % 100000).toString().padLeft(5, '0');
    return '$p$seq';
  }

  /// Public for settings validation / tests.
  static String normalizePrefix(String? prefix) {
    if (prefix == null || prefix.trim().isEmpty) return defaultPrefix;
    final cleaned = prefix.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    if (cleaned.isEmpty) return defaultPrefix;
    // Keep prefixes short for list UI.
    return cleaned.length > 8 ? cleaned.substring(0, 8) : cleaned;
  }

  void _incrementCounter() {
    final next = _counter + 1;
    if (next >= 100000) {
      // Wrap-around: warn via throw so callers can handle (e.g., change prefix).
      throw StateError(
        'SKU counter overflow for current prefix — '
        'generated 100000 SKUs, consider using a different prefix.',
      );
    }
    _counter = next;
  }
}
