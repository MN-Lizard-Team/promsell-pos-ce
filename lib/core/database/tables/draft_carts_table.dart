import 'package:drift/drift.dart';

@DataClassName('DraftCartData')
class DraftCarts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get cartDiscountType => text().nullable()();
  RealColumn get cartDiscountValue => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
