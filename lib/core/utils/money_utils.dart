import 'package:promsell_pos_ce/core/domain/money.dart';

/// Centralized money utility helpers.
class MoneyUtils {
  MoneyUtils._();

  /// Legacy: rounds a double to 2 decimal places (half-up) for currency.
  ///
  /// @deprecated Use [Money] value object for new code.
  static double round(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /// Sums an iterable of [Money] values. Returns [Money.zero] for empty input.
  static Money sum(Iterable<Money> values) =>
      values.fold(Money.zero, (a, b) => a + b);
}
