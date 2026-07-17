import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';

/// Shared write-side helpers for sale create/void (inside caller's transaction).
class SaleWriteSideEffects {
  SaleWriteSideEffects(this._db);

  final AppDatabase _db;

  /// Fail closed when a sale references a missing, deleted, or inactive promo.
  Future<void> assertPromotionActive(String promotionId) async {
    final now = DateTime.now();
    final row =
        await (_db.select(_db.promotions)
              ..where((p) => p.id.equals(promotionId))
              ..where((p) => p.deletedAt.isNull())
              ..where((p) => p.isActive.equals(true)))
            .getSingleOrNull();
    if (row == null) {
      throw NotFoundError('Promotion', id: promotionId);
    }
    if (now.isBefore(row.startDate)) {
      throw NotFoundError('Promotion', id: promotionId);
    }
    if (row.endDate != null && now.isAfter(row.endDate!)) {
      throw NotFoundError('Promotion', id: promotionId);
    }
  }

  /// Updates a customer's lifetime [totalSpent] and [visitCount] by absolute
  /// deltas, re-reading the current row inside the caller's transaction.
  ///
  /// When [requireActive] is true (sale create), missing/soft-deleted customers
  /// fail closed. Void reversal keeps soft-deleted rows so history can unwind.
  Future<void> applyCustomerSpentDelta({
    required String customerId,
    required Money delta,
    required int visitDelta,
    bool requireActive = false,
  }) async {
    final query = _db.select(_db.customers)
      ..where((c) => c.id.equals(customerId));
    if (requireActive) {
      query.where((c) => c.deletedAt.isNull());
    }
    final customer = await query.getSingleOrNull();
    if (customer == null) {
      if (requireActive) {
        throw NotFoundError('Customer', id: customerId);
      }
      return;
    }
    final currentSpent = Money.fromDouble(customer.totalSpent);
    final newTotalSpent = (currentSpent + delta).clampToZero();
    final newVisitCount = (customer.visitCount + visitDelta).clamp(0, 1 << 31);
    await (_db.update(
      _db.customers,
    )..where((c) => c.id.equals(customerId))).write(
      CustomersCompanion(
        totalSpent: Value(newTotalSpent.value),
        visitCount: Value(newVisitCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
