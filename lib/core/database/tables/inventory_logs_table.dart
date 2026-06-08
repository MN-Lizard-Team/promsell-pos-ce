import 'package:drift/drift.dart';

@DataClassName('InventoryLogData')
class InventoryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get type => text()();
  IntColumn get qtyChange => integer()();
  IntColumn get balanceAfter => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get refSaleId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
