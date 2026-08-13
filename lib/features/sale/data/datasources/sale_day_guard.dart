import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';

/// Database-authoritative day-close checks for sale mutations.
///
/// Use-case checks provide early UI feedback, but these checks run inside the
/// sale/void transaction so a stale settings snapshot cannot bypass the lock.
abstract final class SaleDayGuard {
  static Future<void> assertCreateAllowed(
    AppDatabase db, {
    DateTime? now,
  }) async {
    final date = SalesDayLock.todayIso(now);
    await _assertAllowed(db, date);
  }

  static Future<void> assertVoidAllowed(
    AppDatabase db,
    DateTime saleCreatedAt,
  ) async {
    await _assertAllowed(db, SalesDayLock.dateIso(saleCreatedAt));
  }

  static Future<void> _assertAllowed(AppDatabase db, String date) async {
    final rows = await (db.select(
      db.appSettings,
    )..where((s) => s.key.isIn(['dailyCloseLock', 'lastClosedDate']))).get();
    final values = {for (final row in rows) row.key: row.value};
    final lockEnabled =
        values['dailyCloseLock'] == 'true' || values['dailyCloseLock'] == '1';
    if (!lockEnabled) return;

    final closedDate = SalesDayLock.normalizeClosedDate(
      values['lastClosedDate'],
    );
    if (closedDate == date) {
      throw const BusinessRuleError(SalesDayLock.ruleDayClosed);
    }

    final closeRow =
        await (db.select(db.dailyCloses)..where(
              (close) =>
                  close.closeDate.equals(date) & close.closedAt.isNotNull(),
            ))
            .getSingleOrNull();
    if (closeRow != null) {
      throw const BusinessRuleError(SalesDayLock.ruleDayClosed);
    }
  }
}
