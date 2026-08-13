import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware date/time formatting utility.
///
/// Centralizes all date/time formatting so adding new locales requires
/// only updating [_localeFor] and the pattern maps below.
class DateFormatter {
  DateFormatter._();

  /// Maps app language codes to intl locale strings.
  ///
  /// Add new locales here when the app gains new supported languages.
  static String _localeFor(String languageCode) {
    return switch (languageCode) {
      'th' => 'th_TH',
      'en' => 'en_US',
      _ => 'en_US',
    };
  }

  /// Returns the intl locale string for the given [context].
  static String localeOf(BuildContext context) {
    return _localeFor(Localizations.localeOf(context).languageCode);
  }

  /// "27 ก.ค. 2026 • 10:37" — date + time with bullet separator.
  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final locale = localeOf(context);
    final date = DateFormat('d MMM yyyy', locale).format(dateTime);
    final time = DateFormat.Hm(locale).format(dateTime);
    return '$date • $time';
  }

  /// "27 ก.ค. 2026" — date only, short month.
  static String formatDate(BuildContext context, DateTime dateTime) {
    return DateFormat('d MMM yyyy', localeOf(context)).format(dateTime);
  }

  /// "10:37" — time only, 24-hour.
  static String formatTime(BuildContext context, DateTime dateTime) {
    return DateFormat.Hm(localeOf(context)).format(dateTime);
  }

  /// "27 ก.ค. 2026 • 10:37 • บิลที่ 3" — date + time + suffix.
  static String formatDateTimeWithSuffix(
    BuildContext context,
    DateTime dateTime,
    String suffix,
  ) {
    return '${formatDateTime(context, dateTime)} • $suffix';
  }
}
