import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';

class AdjustStock {
  const AdjustStock(this._db, this._inventoryLogService);
  final AppDatabase _db;
  final InventoryLogService _inventoryLogService;

  /// Adjust stock for [productId] by [qtyChange] (positive = add, negative = remove).
  /// [reason] is required for audit trail.
  /// Throws [StateError] if product not found or result stock < 0.
  Future<void> call({
    required String productId,
    required int qtyChange,
    required String reason,
  }) async {
    await _db.transaction(() async {
      final product = await (_db.select(
        _db.products,
      )..where((p) => p.id.equals(productId))).getSingleOrNull();

      if (product == null) {
        throw StateError('Product not found: $productId');
      }

      final newStock = product.stock + qtyChange;
      if (newStock < 0) {
        throw StateError(
          'Resulting stock cannot be negative: '
          'current ${product.stock}, change $qtyChange',
        );
      }

      await (_db.update(
        _db.products,
      )..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(
          stock: Value(newStock),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await _inventoryLogService.logAdjustment(
        productId: productId,
        qtyChange: qtyChange,
        reason: reason,
        balanceAfter: newStock,
      );
    });
  }
}
