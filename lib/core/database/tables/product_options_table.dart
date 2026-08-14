import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/core/database/tables/product_option_groups_table.dart';

@DataClassName('ProductOptionData')
class ProductOptions extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(
    ProductOptionGroups,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get priceDelta => real().withDefault(const Constant(0))();
  // Phase M (C1): INTEGER satang dual-write column.
  IntColumn get priceDeltaSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
