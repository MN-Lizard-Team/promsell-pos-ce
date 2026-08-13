/// Shared calendar day ranges for Report and History date presets.
class DateRangePresets {
  DateRangePresets._();

  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999, 999);

  static (DateTime from, DateTime to) today([DateTime? now]) {
    final n = now ?? DateTime.now();
    return (startOfDay(n), endOfDay(n));
  }

  static (DateTime from, DateTime to) yesterday([DateTime? now]) {
    final n = now ?? DateTime.now();
    final y = startOfDay(n).subtract(const Duration(days: 1));
    return (y, endOfDay(y));
  }

  static (DateTime from, DateTime to) last7Days([DateTime? now]) {
    final n = now ?? DateTime.now();
    final end = endOfDay(n);
    final start = startOfDay(n).subtract(const Duration(days: 6));
    return (start, end);
  }

  static (DateTime from, DateTime to) thisMonth([DateTime? now]) {
    final n = now ?? DateTime.now();
    final start = DateTime(n.year, n.month, 1);
    return (start, endOfDay(n));
  }

  /// Which preset matches [from]/[to], or null if custom.
  static DateRangePresetKind? match(
    DateTime from,
    DateTime to, [
    DateTime? now,
  ]) {
    final n = now ?? DateTime.now();
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final t = today(n);
    if (same(from, t.$1) && same(to, t.$2)) return DateRangePresetKind.today;

    final y = yesterday(n);
    if (same(from, y.$1) && same(to, y.$2)) {
      return DateRangePresetKind.yesterday;
    }

    final w = last7Days(n);
    if (same(from, w.$1) && same(to, w.$2)) {
      return DateRangePresetKind.last7Days;
    }

    final m = thisMonth(n);
    if (same(from, m.$1) && same(to, m.$2)) {
      return DateRangePresetKind.thisMonth;
    }

    return null;
  }
}

enum DateRangePresetKind { today, yesterday, last7Days, thisMonth, custom }
