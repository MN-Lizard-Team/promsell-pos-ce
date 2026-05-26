import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:promsell_pos_ce/core/database/tables/products_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sale_items_table.dart';
import 'package:promsell_pos_ce/core/database/tables/sales_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Products, Sales, SaleItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {},
  );

  static QueryExecutor _openDatabase() {
    return driftDatabase(name: 'promsell_pos.db');
  }
}
