import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';

void main() {
  group('MoneyUtils.sum', () {
    test('returns zero for empty iterable', () {
      expect(MoneyUtils.sum([]), Money.zero);
    });

    test('sums single value', () {
      expect(
        MoneyUtils.sum([Money.fromDouble(10.50)]),
        Money.fromDouble(10.50),
      );
    });

    test('sums multiple values', () {
      expect(
        MoneyUtils.sum([Money.fromDouble(10.50), Money.fromDouble(20.00)]),
        Money.fromDouble(30.50),
      );
    });

    test('handles zero values', () {
      expect(
        MoneyUtils.sum([Money.zero, Money.fromDouble(5.00)]),
        Money.fromDouble(5.00),
      );
    });
  });
}
