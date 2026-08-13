import 'package:intl/intl.dart';

/// Global month name helpers supporting en/th locales, both short and full.
///
/// Usage:
/// ```dart
/// final short = MonthName.short(DateTime.january, locale: 'th'); // "ม.ค."
/// final full = MonthName.full(DateTime.february, locale: 'en');  // "February"
/// ```
class MonthName {
  MonthName._();

  /// Short month name (e.g. "Jan", "ม.ค.").
  static String short(int month, {String locale = 'en'}) {
    return _format(month, 'MMM', locale);
  }

  /// Full month name (e.g. "January", "มกราคม").
  static String full(int month, {String locale = 'en'}) {
    return _format(month, 'MMMM', locale);
  }

  /// Returns all 12 short month names for the given locale.
  static List<String> allShort({String locale = 'en'}) {
    return [for (var m = 1; m <= 12; m++) short(m, locale: locale)];
  }

  /// Returns all 12 full month names for the given locale.
  static List<String> allFull({String locale = 'en'}) {
    return [for (var m = 1; m <= 12; m++) full(m, locale: locale)];
  }

  static String _format(int month, String pattern, String locale) {
    // Use a reference date to extract the localized month name.
    final ref = DateTime(2024, month, 15);
    return DateFormat(pattern, locale).format(ref);
  }
}

/// Extension on [DateTime] for convenient localized month name access.
extension MonthNameDateTimeX on DateTime {
  /// Short localized month name, e.g. "Jan" or "ม.ค.".
  String monthShort({String locale = 'en'}) =>
      MonthName.short(month, locale: locale);

  /// Full localized month name, e.g. "January" or "มกราคม".
  String monthFull({String locale = 'en'}) =>
      MonthName.full(month, locale: locale);
}
