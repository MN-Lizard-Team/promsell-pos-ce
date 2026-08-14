import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';

@DataClassName('DailyCloseData')
class DailyCloses extends Table {
  TextColumn get id => text()();
  TextColumn get closeDate => text()();
  RealColumn get openingCash => real().withDefault(const Constant(0))();
  RealColumn get expectedCash => real().withDefault(const Constant(0))();
  RealColumn get countedCash => real().withDefault(const Constant(0))();
  RealColumn get overShortAmount => real().withDefault(const Constant(0))();
  RealColumn get totalRevenue => real().withDefault(const Constant(0))();
  RealColumn get totalVoid => real().withDefault(const Constant(0))();
  IntColumn get salesCount => integer().withDefault(const Constant(0))();
  IntColumn get voidCount => integer().withDefault(const Constant(0))();
  TextColumn get paymentBreakdown => text().withDefault(const Constant('{}'))();
  RealColumn get vatAmount => real().withDefault(const Constant(0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  // Phase M (C1): INTEGER satang dual-write columns.
  IntColumn get openingCashSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get expectedCashSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get countedCashSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get overShortAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get totalRevenueSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get totalVoidSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get vatAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get discountAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  TextColumn get note => text().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
