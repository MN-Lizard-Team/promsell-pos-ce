import 'package:equatable/equatable.dart';

/// Immutable monetary value stored as integer minor units (สตางค์ / cents).
///
/// Using integer minor units eliminates all IEEE-754 floating-point rounding
/// errors that plague `double`-based money arithmetic (e.g. ฿0.10 × 3 ≠ ฿0.30
/// in floating point). All arithmetic is performed in satang (1/100 of a Baht).
///
/// ## Creating Money values
/// ```dart
/// final price = Money.fromDouble(99.50);   // ฿99.50 (9950 satang)
/// final zero  = Money.zero;
/// ```
///
/// ## Arithmetic
/// ```dart
/// final total = price * 3;                 // ฿298.50
/// final vat   = total * 0.07;              // ฿20.90 (half-up rounded)
/// final sum   = price + vat;               // ฿120.40
/// final diff  = total - price;             // ฿199.00 (clamps to zero)
/// ```
///
/// ## Persistence (Drift)
/// Use [MoneyConverter] to persist as REAL (double) in SQLite.
/// The stored value is the decimal Baht amount (e.g. 99.50), not satang.
class Money extends Equatable implements Comparable<Money> {
  const Money._(this._satang);

  final int _satang;

  // ---------------------------------------------------------------------------
  // Constants & Factories
  // ---------------------------------------------------------------------------

  static const Money zero = Money._(0);

  /// Creates a [Money] from a decimal Baht [value].
  /// Uses round-half-up rounding to the nearest satang.
  factory Money.fromDouble(double value) {
    // Multiply by 100 and round to nearest integer with half-up rule.
    final satang = (value * 100 + (value >= 0 ? 0.5 : -0.5)).truncate();
    return Money._(satang);
  }

  // ---------------------------------------------------------------------------
  // Accessors
  // ---------------------------------------------------------------------------

  /// The decimal Baht value (e.g. 99.50). Use for display and persistence only.
  double get value => _satang / 100.0;

  /// Raw satang (minor units) value. Use for exact arithmetic.
  int get satang => _satang;

  bool get isZero => _satang == 0;
  bool get isPositive => _satang > 0;
  bool get isNegative => _satang < 0;

  // ---------------------------------------------------------------------------
  // Arithmetic
  // ---------------------------------------------------------------------------

  Money operator +(Money other) => Money._(_satang + other._satang);

  /// Subtraction clamped at zero (prevents negative balances in cart/stock).
  Money operator -(Money other) {
    final result = _satang - other._satang;
    return Money._(result < 0 ? 0 : result);
  }

  /// Unclamped subtraction — use when negative values are valid (e.g. over-short).
  Money subtractUnclamped(Money other) => Money._(_satang - other._satang);

  /// Multiplies by a [factor] and rounds half-up to the nearest satang.
  Money operator *(num factor) {
    final product = _satang * factor;
    return Money._((product + (product >= 0 ? 0.5 : -0.5)).truncate());
  }

  Money clampToZero() => _satang < 0 ? Money.zero : this;

  /// Unary negation — use only for display of over-short amounts.
  Money operator -() => Money._(-_satang);

  // ---------------------------------------------------------------------------
  // Comparison
  // ---------------------------------------------------------------------------

  @override
  int compareTo(Money other) => _satang.compareTo(other._satang);

  bool operator >(Money other) => _satang > other._satang;
  bool operator >=(Money other) => _satang >= other._satang;
  bool operator <(Money other) => _satang < other._satang;
  bool operator <=(Money other) => _satang <= other._satang;

  // ---------------------------------------------------------------------------
  // Equatable
  // ---------------------------------------------------------------------------

  @override
  List<Object?> get props => [_satang];

  @override
  String toString() => 'Money(${value.toStringAsFixed(2)})';
}
