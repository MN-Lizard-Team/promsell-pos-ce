import 'package:intl/intl.dart';

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

  static String format(double amount) => _formatter.format(amount);

  static String formatNoDecimal(double amount) =>
      _formatterNoDecimal.format(amount);

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '฿${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '฿${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
