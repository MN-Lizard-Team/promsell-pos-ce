import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/datasources/inventory_log_local_datasource.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/inventory/domain/repositories/inventory_repository.dart';

@LazySingleton(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._db, this._logDatasource);

  final AppDatabase _db;
  final InventoryLogLocalDatasource _logDatasource;

  @override
  Future<void> adjustStock({
    required String productId,
    required int qtyChange,
    required String reason,
  }) async {
    await _db.transaction(() async {
      // Get current product (exclude soft-deleted rows).
      final product =
          await (_db.select(_db.products)
                ..where((p) => p.id.equals(productId) & p.deletedAt.isNull()))
              .getSingleOrNull();

      if (product == null) {
        throw StateError('Product not found or deleted: $productId');
      }

      // Refuse stock adjustments on products that don't track stock.
      if (!product.trackStock) {
        throw StateError(
          'Cannot adjust stock: product "$productId" does not track stock.',
        );
      }

      final now = DateTime.now();
      if (qtyChange < 0) {
        // Atomic: refuse if would go negative.
        final rows = await _db.customUpdate(
          'UPDATE products SET stock = stock + ?, updated_at = ? '
          'WHERE id = ? AND stock + ? >= 0',
          variables: [
            Variable.withInt(qtyChange),
            Variable.withDateTime(now),
            Variable.withString(productId),
            Variable.withInt(qtyChange),
          ],
          updates: {_db.products},
        );
        if (rows == 0) {
          throw StateError(
            'Resulting stock cannot be negative: '
            'current ${product.stock}, change $qtyChange',
          );
        }
      } else {
        await _db.customUpdate(
          'UPDATE products SET stock = stock + ?, updated_at = ? '
          'WHERE id = ?',
          variables: [
            Variable.withInt(qtyChange),
            Variable.withDateTime(now),
            Variable.withString(productId),
          ],
          updates: {_db.products},
        );
      }

      final balRow = await (_db.select(
        _db.products,
      )..where((p) => p.id.equals(productId))).getSingle();

      // Log the adjustment
      final logType = qtyChange > 0 ? 'ADJUSTMENT_IN' : 'ADJUSTMENT_OUT';
      await _logDatasource.insertLog(
        InventoryLogsCompanion.insert(
          id: IdGenerator.newId(),
          productId: productId,
          type: logType,
          qtyChange: qtyChange,
          balanceAfter: balRow.stock,
          reason: Value(reason),
          createdAt: Value(now),
        ),
      );
    });
  }

  @override
  Stream<List<InventoryLog>> watchInventoryLogs(String productId) {
    return _logDatasource.watchLogsByProduct(productId);
  }

  @override
  Future<List<InventoryLog>> getAllLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _logDatasource.getLogsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
