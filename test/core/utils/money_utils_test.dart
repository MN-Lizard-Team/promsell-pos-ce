import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';

void main() {
  group('MoneyUtils.round', () {
    test('rounds to 2 decimal places', () {
      expect(MoneyUtils.round(33.335), 33.34);
    });

    test('rounds down correctly', () {
      expect(MoneyUtils.round(33.334), 33.33);
    });

    test('handles whole numbers', () {
      expect(MoneyUtils.round(100), 100.0);
    });

    test('handles zero', () {
      expect(MoneyUtils.round(0), 0.0);
    });

    test('handles negative numbers', () {
      expect(MoneyUtils.round(-33.335), -33.34);
    });

    test('handles single decimal', () {
      expect(MoneyUtils.round(10.5), 10.5);
    });

    test('handles many decimals', () {
      expect(MoneyUtils.round(10.123456789), 10.12);
    });
  });
}
