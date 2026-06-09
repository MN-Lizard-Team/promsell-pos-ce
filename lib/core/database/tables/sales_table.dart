import 'package:drift/drift.dart';

@DataClassName('SaleData')
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get receiptNumber => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))();
  RealColumn get subtotalAmount => real().withDefault(const Constant(0))();
  TextColumn get discountType => text().nullable()();
  RealColumn get discountValue => real().nullable()();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get totalAmount => real()();
  TextColumn get vatMode => text().withDefault(const Constant('NONE'))();
  RealColumn get vatRate => real().withDefault(const Constant(0))();
  RealColumn get vatAmount => real().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text()();
  RealColumn get amountReceived => real().nullable()();
  RealColumn get changeAmount => real().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get paymentReference => text().nullable()();
  TextColumn get sendingBankCode => text().nullable()();
  DateTimeColumn get voidedAt => dateTime().nullable()();
  TextColumn get voidReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
