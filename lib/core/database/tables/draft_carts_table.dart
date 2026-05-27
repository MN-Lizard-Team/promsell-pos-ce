import 'package:drift/drift.dart';

@DataClassName('DraftCartData')
class DraftCarts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
