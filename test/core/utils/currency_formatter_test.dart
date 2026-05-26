import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('format returns baht symbol with 2 decimals', () {
      final result = CurrencyFormatter.format(1234.5);
      expect(result, contains('฿'));
      expect(result, contains('1,234.50'));
    });

    test('formatNoDecimal returns baht symbol with 0 decimals', () {
      final result = CurrencyFormatter.formatNoDecimal(1234.5);
      expect(result, contains('฿'));
      expect(result, contains('1,235'));
    });

    test('formatCompact returns M suffix for millions', () {
      expect(CurrencyFormatter.formatCompact(1500000), '฿1.5M');
    });

    test('formatCompact returns K suffix for thousands', () {
      expect(CurrencyFormatter.formatCompact(2500), '฿2.5K');
    });

    test('formatCompact falls back to format for small amounts', () {
      final result = CurrencyFormatter.formatCompact(500);
      expect(result, contains('฿'));
      expect(result, contains('500'));
    });

    test('format handles zero', () {
      final result = CurrencyFormatter.format(0);
      expect(result, contains('0.00'));
    });
  });
}
