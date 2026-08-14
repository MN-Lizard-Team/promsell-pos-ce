import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';

@DataClassName('DraftCartData')
class DraftCarts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get cartDiscountType => text().nullable()();
  RealColumn get cartDiscountValue => real().nullable()();
  IntColumn get cartDiscountValueSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  TextColumn get orderType => text().withDefault(const Constant('delivery'))();
  TextColumn get orderChannel => text().withDefault(const Constant('walkin'))();
  TextColumn get externalOrderRef => text().nullable()();
  TextColumn get tableId => text().nullable()();
  RealColumn get serviceChargeRate => real().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get promotionId => text().nullable()();
  RealColumn get promotionDiscountAmount =>
      real().withDefault(const Constant(0))();
  // Phase M (C1): INTEGER satang dual-write column.
  // cartDiscountValue stays REAL for compatibility; its satang column is
  // populated only when cartDiscountType is AMOUNT.
  // serviceChargeRate stays REAL (rate, not money).
  IntColumn get promotionDiscountAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
