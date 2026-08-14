import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';

@DataClassName('CustomerData')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get note => text().nullable()();
  RealColumn get totalSpent => real().withDefault(const Constant(0))();
  // Phase M (C1): INTEGER satang dual-write column.
  IntColumn get totalSpentSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get visitCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
