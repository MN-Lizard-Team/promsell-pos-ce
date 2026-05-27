import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/tables/sales_table.dart';

@DataClassName('SaleItemData')
class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId =>
      text().references(Sales, #id, onDelete: KeyAction.cascade)();
  // Intentionally no FK to Products — sale history must survive product deletion.
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get price => real()();
  IntColumn get qty => integer()();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get vatAmount => real().withDefault(const Constant(0))();
  RealColumn get subtotal => real()();

  @override
  Set<Column> get primaryKey => {id};
}
