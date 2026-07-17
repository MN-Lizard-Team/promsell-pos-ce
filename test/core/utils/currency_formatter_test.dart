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

    test('formatGrouped adds thousand separators with 2 decimals', () {
      expect(CurrencyFormatter.formatGrouped(1234.5), '1,234.50');
      expect(CurrencyFormatter.formatGrouped(99999.99), '99,999.99');
      expect(CurrencyFormatter.formatGrouped(0), '0.00');
    });

    test('formatGroupedWithSymbol prefixes currency symbol', () {
      expect(CurrencyFormatter.formatGroupedWithSymbol(1500, '฿'), '฿1,500.00');
      expect(CurrencyFormatter.formatGroupedWithSymbol(-50.25, '฿'), '฿-50.25');
    });

    test('formatGroupedInt adds thousand separators', () {
      expect(CurrencyFormatter.formatGroupedInt(12345), '12,345');
      expect(CurrencyFormatter.formatGroupedInt(0), '0');
    });
  });
}
