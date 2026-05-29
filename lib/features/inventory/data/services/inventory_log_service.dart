import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';

@lazySingleton
class InventoryLogService {
  InventoryLogService(this._db);
  final AppDatabase _db;

  /// Log stock deduction from a sale.
  /// [qty] must be positive; stored as negative `qtyChange`.
  Future<void> logSale({
    required String productId,
    required int qty,
    required String saleId,
    required int balanceAfter,
  }) => _insert(
    productId: productId,
    type: 'SALE',
    qtyChange: -qty,
    balanceAfter: balanceAfter,
    refSaleId: saleId,
  );

  /// Log stock restoration from a voided sale.
  /// [qty] must be positive; stored as positive `qtyChange`.
  Future<void> logVoidReversal({
    required String productId,
    required int qty,
    required String saleId,
    required int balanceAfter,
  }) => _insert(
    productId: productId,
    type: 'VOID_REVERSAL',
    qtyChange: qty,
    balanceAfter: balanceAfter,
    refSaleId: saleId,
  );

  /// Log a manual stock adjustment.
  /// [qtyChange] is signed: positive = add, negative = remove.
  Future<void> logAdjustment({
    required String productId,
    required int qtyChange,
    required String reason,
    required int balanceAfter,
  }) => _insert(
    productId: productId,
    type: qtyChange >= 0 ? 'ADJUSTMENT_IN' : 'ADJUSTMENT_OUT',
    qtyChange: qtyChange,
    balanceAfter: balanceAfter,
    reason: reason,
  );

  Future<void> _insert({
    required String productId,
    required String type,
    required int qtyChange,
    required int balanceAfter,
    String? refSaleId,
    String? reason,
  }) async {
    await _db
        .into(_db.inventoryLogs)
        .insert(
          InventoryLogsCompanion.insert(
            id: IdGenerator.newId(),
            productId: productId,
            type: type,
            qtyChange: qtyChange,
            balanceAfter: balanceAfter,
            reason: Value(reason),
            refSaleId: Value(refSaleId),
          ),
        );
  }
}
