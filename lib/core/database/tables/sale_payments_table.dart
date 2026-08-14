import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/core/database/tables/sales_table.dart';

/// Payment tender lines for a sale (multi-tender support).
@DataClassName('SalePaymentData')
class SalePayments extends Table {
  TextColumn get id => text()();
  TextColumn get saleId =>
      text().references(Sales, #id, onDelete: KeyAction.cascade)();

  /// Normalized method: cash | transfer | card | promptpay | ...
  TextColumn get method => text()();
  RealColumn get amount => real()();
  // Phase M (C1): INTEGER satang dual-write column.
  IntColumn get amountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  TextColumn get reference => text().nullable()();
  TextColumn get sendingBankCode => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
