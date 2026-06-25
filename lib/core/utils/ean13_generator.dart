import 'package:injectable/injectable.dart';

/// Generates EAN-13 compliant barcodes with Luhn check digit.
///
/// Format: [prefix (3 digits)] + [timestamp(4 digits)] + [counter(5 digits)] + [check digit (1)]
/// Total: 13 digits.
@injectable
class Ean13Generator {
  Ean13Generator();

  /// GS1 internal use range (200–299) — safe for in-store generated barcodes.
  static const String defaultPrefix = '200';

  int _counter = 0;

  /// Initializes the internal counter from a persisted value.
  /// Call at app startup with the last saved counter from Settings.
  void initCounter(int value) {
    _counter = value % 100000;
  }

  /// Current counter value — persist this to Settings after each generate.
  int get currentCounter => _counter;

  /// Generates a 13-digit EAN-13 barcode.
  ///
  /// [prefix] must be 1–3 numeric digits. Padded to 3 digits with leading zeros.
  /// Defaults to "200" (GS1 internal use).
  /// The remaining digits are derived from timestamp + counter to ensure uniqueness.
  String generate({String? prefix}) {
    final raw = (prefix == null || prefix.isEmpty) ? defaultPrefix : prefix;
    if (!RegExp(r'^[0-9]{1,3}$').hasMatch(raw)) {
      throw ArgumentError('Prefix must be 1–3 numeric digits, got: "$raw"');
    }
    final p = raw.padLeft(3, '0');
    final now = DateTime.now();
    final timePart = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );
    _incrementCounter();
    final counterPart = (_counter % 100000).toString().padLeft(5, '0');
    final twelveDigits = '$p$timePart$counterPart';
    final checkDigit = _computeCheckDigit(twelveDigits);
    return '$twelveDigits$checkDigit';
  }

  /// Computes the EAN-13 check digit using the standard Luhn-like algorithm.
  ///
  /// Weights: odd positions (1, 3, 5, ...) × 1, even positions (2, 4, 6, ...) × 3.
  static int _computeCheckDigit(String twelveDigits) {
    var sum = 0;
    for (var i = 0; i < twelveDigits.length; i++) {
      final digit = int.parse(twelveDigits[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    final remainder = sum % 10;
    return remainder == 0 ? 0 : 10 - remainder;
  }

  void _incrementCounter() {
    _counter = (_counter + 1) % 100000;
  }
}
