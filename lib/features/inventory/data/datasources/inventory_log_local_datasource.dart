import 'package:drift/drift.dart' hide Column;
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';

@lazySingleton
class InventoryLogLocalDatasource {
  InventoryLogLocalDatasource(this._db);
  final AppDatabase _db;

  /// Cap per product watch so History UI stays responsive on high-volume SKUs.
  static const int productLogLimit = 200;

  Stream<List<InventoryLog>> watchLogsByProduct(String productId) {
    final query = _db.select(_db.inventoryLogs)
      ..where((t) => t.productId.equals(productId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(productLogLimit);
    return query.watch().map((rows) => rows.map(_fromData).toList());
  }

  Future<List<InventoryLog>> getLogsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _db.select(_db.inventoryLogs)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    if (startDate != null) {
      query = query..where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query = query..where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
    }

    final rows = await query.get();
    return rows.map(_fromData).toList();
  }

  Future<void> insertLog(InventoryLogsCompanion companion) async {
    await _db.into(_db.inventoryLogs).insert(companion);
  }

  InventoryLog _fromData(InventoryLogData d) => InventoryLog(
    id: d.id,
    productId: d.productId,
    type: d.type,
    qtyChange: d.qtyChange,
    balanceAfter: d.balanceAfter,
    reason: d.reason,
    refSaleId: d.refSaleId,
    createdAt: d.createdAt,
    deviceId: d.deviceId,
    updatedAt: d.updatedAt,
    deletedAt: d.deletedAt,
    version: d.version,
  );

  // Legacy method for backward compatibility
  Stream<List<InventoryLogData>> watchLogs({String? productId}) {
    final query = _db.select(_db.inventoryLogs)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (productId != null) {
      query.where((t) => t.productId.equals(productId));
      query.limit(productLogLimit);
    }
    return query.watch();
  }
}
