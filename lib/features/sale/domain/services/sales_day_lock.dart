/// Shared day-close lock rules for create checkout and void.
///
/// SSOT for flags: settings [dailyCloseLock] + [lastClosedDate] (yyyy-MM-dd).
/// Void may also pass [dayRowClosed] from daily_closes.closedAt.
abstract final class SalesDayLock {
  static const ruleDayClosed = 'DayClosed';

  /// Local calendar date as `yyyy-MM-dd`.
  static String dateIso(DateTime d) {
    final local = d.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String todayIso([DateTime? now]) => dateIso(now ?? DateTime.now());

  static String? normalizeClosedDate(String? lastClosedDate) {
    if (lastClosedDate == null) return null;
    final t = lastClosedDate.trim();
    return t.isEmpty ? null : t;
  }

  /// Block new sales when lock is on and last closed date is **today**.
  static bool isCreateBlocked({
    required bool dailyCloseLock,
    required String? lastClosedDate,
    DateTime? now,
  }) {
    if (!dailyCloseLock) return false;
    final closed = normalizeClosedDate(lastClosedDate);
    if (closed == null) return false;
    return closed == todayIso(now);
  }

  /// Block void when lock is on and the sale's day is closed
  /// (settings lastClosedDate match and/or closed daily_close row).
  static bool isVoidBlocked({
    required bool dailyCloseLock,
    required String? lastClosedDate,
    required DateTime saleCreatedAt,
    bool? dayRowClosed,
  }) {
    if (!dailyCloseLock) return false;
    final saleDate = dateIso(saleCreatedAt);
    final closed = normalizeClosedDate(lastClosedDate);
    if (closed != null && closed == saleDate) return true;
    if (dayRowClosed == true) return true;
    return false;
  }
}
