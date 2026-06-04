/// Centralized money rounding utility.
///
/// All monetary calculations MUST use [MoneyUtils.round] before storing
/// or displaying to avoid floating-point drift (e.g. 33.335 → 33.34).
class MoneyUtils {
  MoneyUtils._();

  /// Round [value] to 2 decimal places (half-up) for currency.
  static double round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}
