import 'package:promsell_pos_ce/core/domain/money.dart';

/// Centralized money utility helpers.
class MoneyUtils {
  MoneyUtils._();

  /// Sums an iterable of [Money] values. Returns [Money.zero] for empty input.
  static Money sum(Iterable<Money> values) =>
      values.fold(Money.zero, (a, b) => a + b);
}
