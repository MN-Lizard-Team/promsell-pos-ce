import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';

@DataClassName('SaleData')
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get receiptNumber => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))();
  RealColumn get subtotalAmount => real().withDefault(const Constant(0))();
  TextColumn get discountType => text().nullable()();
  RealColumn get discountValue => real().nullable()();
  IntColumn get discountValueSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  RealColumn get totalAmount => real()();
  TextColumn get vatMode => text().withDefault(const Constant('NONE'))();
  RealColumn get vatRate => real().withDefault(const Constant(0))();
  RealColumn get vatAmount => real().withDefault(const Constant(0))();
  TextColumn get orderType => text().withDefault(const Constant('delivery'))();
  TextColumn get orderChannel => text().withDefault(const Constant('walkin'))();
  TextColumn get externalOrderRef => text().nullable()();
  TextColumn get tableId => text().nullable()();
  RealColumn get serviceChargeRate => real().withDefault(const Constant(0))();
  RealColumn get serviceChargeAmount => real().withDefault(const Constant(0))();
  TextColumn get customerId => text().nullable()();
  TextColumn get promotionId => text().nullable()();
  RealColumn get promotionDiscountAmount =>
      real().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text()();
  RealColumn get amountReceived => real().nullable()();
  RealColumn get changeAmount => real().nullable()();
  // Phase M (C1): INTEGER satang dual-write columns for amount fields.
  // Rates (vatRate, serviceChargeRate) stay REAL. `discountValueSatang` is
  // populated only when discountType is AMOUNT; percent values stay REAL.
  IntColumn get subtotalAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get discountAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get totalAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get vatAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get serviceChargeAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get promotionDiscountAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get amountReceivedSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get changeAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
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
