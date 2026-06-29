import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/tables/draft_carts_table.dart';

@DataClassName('DraftCartItemData')
class DraftCartItems extends Table {
  TextColumn get id => text()();
  TextColumn get cartId =>
      text().references(DraftCarts, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get price => real()();
  IntColumn get qty => integer()();
  TextColumn get discountType => text().nullable()();
  RealColumn get discountValue => real().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
