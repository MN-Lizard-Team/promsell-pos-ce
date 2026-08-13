import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_day_guard.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_side_effects.dart';

/// Void sale + stock restore + inventory logs (single transaction).
class SaleVoidWriter {
  SaleVoidWriter(
    this._db, {
    required this.inventoryLogService,
    required SaleWriteSideEffects sideEffects,
  }) : _sideEffects = sideEffects;

  final AppDatabase _db;
  final InventoryLogService inventoryLogService;
  final SaleWriteSideEffects _sideEffects;

  Future<void> voidSale(String saleId, {String? reason}) async {
    await _db.transaction(() async {
      final sale =
          await (_db.select(_db.sales)
                ..where((s) => s.id.equals(saleId))
                ..where((s) => s.deletedAt.isNull()))
              .getSingleOrNull();
      if (sale == null) {
        throw NotFoundError('Sale', id: saleId);
      }
      if (sale.status == 'VOIDED') {
        throw const BusinessRuleError('SaleAlreadyVoided');
      }

      await SaleDayGuard.assertVoidAllowed(_db, sale.createdAt);
      final now = DateTime.now();
      await (_db.update(_db.sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(
          status: const Value('VOIDED'),
          voidedAt: Value(now),
          voidReason: Value(reason),
          updatedAt: Value(now),
          version: Value(sale.version + 1),
        ),
      );

      final items = await (_db.select(
        _db.saleItems,
      )..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())).get();

      final productIds = items.map((i) => i.productId).toSet().toList();
      final productRows = productIds.isEmpty
          ? <ProductData>[]
          : await (_db.select(
              _db.products,
            )..where((p) => p.id.isIn(productIds))).get();
      final productMap = {for (final p in productRows) p.id: p};

      final quantitiesByProduct = <String, int>{};
      for (final item in items) {
        quantitiesByProduct.update(
          item.productId,
          (quantity) => quantity + item.qty,
          ifAbsent: () => item.qty,
        );
      }

      for (final entry in quantitiesByProduct.entries) {
        final product = productMap[entry.key];

        if (product == null) {
          // Product deleted — still log reversal but skip stock restore.
          await inventoryLogService.logVoidReversal(
            productId: entry.key,
            qty: entry.value,
            saleId: saleId,
            balanceAfter: -1,
            reason: 'Product deleted since sale',
          );
          continue;
        }

        if (!product.trackStock) {
          await inventoryLogService.logVoidReversal(
            productId: product.id,
            qty: entry.value,
            saleId: saleId,
            balanceAfter: product.stock,
          );
          continue;
        }

        // Atomic restore: stock = stock + qty
        await _db.customUpdate(
          'UPDATE products SET stock = stock + ?, updated_at = ? '
          'WHERE id = ? AND track_stock = 1',
          variables: [
            Variable.withInt(entry.value),
            Variable.withDateTime(now),
            Variable.withString(product.id),
          ],
          updates: {_db.products},
        );
        final balRow = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(product.id))).getSingle();
        await inventoryLogService.logVoidReversal(
          productId: product.id,
          qty: entry.value,
          saleId: saleId,
          balanceAfter: balRow.stock,
        );
      }

      // Reverse customer totals so reporting reflects the void.
      // sale here is SaleData (raw DB row) — totalAmount is still double.
      if (sale.customerId != null) {
        await _sideEffects.applyCustomerSpentDelta(
          customerId: sale.customerId!,
          delta: -Money.fromDouble(sale.totalAmount),
          visitDelta: -1,
        );
      }
    });
  }
}
