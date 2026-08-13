import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'th_TH',
    symbol: '฿',
    decimalDigits: 2,
  );

  static final _formatterNoDecimal = NumberFormat.currency(
    locale: 'th_TH',
    symbol: '฿',
    decimalDigits: 0,
  );

  /// Grouped number with thousand separators, no currency symbol.
  /// Example: `1234.5` → `1,234.50`
  static final _groupedDecimal = NumberFormat('#,##0.00', 'en_US');

  /// Grouped integer with thousand separators.
  /// Example: `12345` → `12,345`
  static final _groupedInteger = NumberFormat('#,##0', 'en_US');

  static String format(double amount) => _formatter.format(amount);

  static String formatNoDecimal(double amount) =>
      _formatterNoDecimal.format(amount);

  /// Formats [amount] with thousand separators and 2 decimal places.
  static String formatGrouped(double amount) => _groupedDecimal.format(amount);

  /// Formats [amount] with thousand separators and a currency [symbol] prefix.
  /// Example: symbol `฿`, amount `1500` → `฿1,500.00`
  static String formatGroupedWithSymbol(
    double amount,
    String symbol, {
    String? locale,
  }) {
    final formatted = locale == null
        ? formatGrouped(amount)
        : NumberFormat('#,##0.00', locale).format(amount);
    return '$symbol$formatted';
  }

  /// Formats an integer quantity with thousand separators.
  static String formatGroupedInt(int value) => _groupedInteger.format(value);

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '฿${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '฿${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  static String formatCompactWithSymbol(double amount, String symbol) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    // Small values: show 2 decimals for consistency with format().
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Formats a [Money] value using the standard Thai Baht format.
  static String formatMoney(Money money) => format(money.value);

  /// Formats a [Money] value with no decimal places.
  static String formatMoneyNoDecimal(Money money) =>
      formatNoDecimal(money.value);

  /// Formats a [Money] value in compact form (K/M suffix for large values).
  static String formatMoneyCompact(Money money) => formatCompact(money.value);

  /// Formats a quantity with K/M suffix for large values.
  static String formatQuantityCompact(int qty) {
    if (qty >= 1000000) {
      return '${(qty / 1000000).toStringAsFixed(1)}M';
    } else if (qty >= 1000) {
      return '${(qty / 1000).toStringAsFixed(1)}K';
    }
    return qty.toString();
  }
}
