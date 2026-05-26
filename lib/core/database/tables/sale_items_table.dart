import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/tables/sales_table.dart';

@DataClassName('SaleItemData')
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId =>
      integer().references(Sales, #id, onDelete: KeyAction.cascade)();
  // Intentionally no FK to Products — sale history must survive product deletion.
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get price => real()();
  IntColumn get qty => integer()();
  RealColumn get subtotal => real()();
}
