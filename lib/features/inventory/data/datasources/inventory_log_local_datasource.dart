import 'package:drift/drift.dart' hide Column;
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

@lazySingleton
class InventoryLogLocalDatasource {
  InventoryLogLocalDatasource(this._db);
  final AppDatabase _db;

  Stream<List<InventoryLogData>> watchLogs({String? productId}) {
    final query = _db.select(_db.inventoryLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (productId != null) {
      query.where((t) => t.productId.equals(productId));
    }
    return query.watch();
  }
}
