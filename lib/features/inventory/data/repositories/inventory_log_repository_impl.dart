import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/inventory/data/datasources/inventory_log_local_datasource.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/inventory/domain/repositories/inventory_log_repository.dart';

@LazySingleton(as: InventoryLogRepository)
class InventoryLogRepositoryImpl implements InventoryLogRepository {
  const InventoryLogRepositoryImpl(this._datasource);
  final InventoryLogLocalDatasource _datasource;

  @override
  Stream<List<InventoryLog>> watchLogs({String? productId}) =>
      _datasource.watchLogs(productId: productId).map(_mapLogs);

  List<InventoryLog> _mapLogs(List<InventoryLogData> data) => data
      .map(
        (d) => InventoryLog(
          id: d.id,
          productId: d.productId,
          type: d.type,
          qtyChange: d.qtyChange,
          balanceAfter: d.balanceAfter,
          reason: d.reason,
          refSaleId: d.refSaleId,
          createdAt: d.createdAt,
        ),
      )
      .toList();
}
