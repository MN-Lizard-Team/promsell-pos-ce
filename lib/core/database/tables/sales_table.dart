import 'package:drift/drift.dart';

@DataClassName('SaleData')
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()();
  RealColumn get amountReceived => real().nullable()();
  RealColumn get changeAmount => real().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
