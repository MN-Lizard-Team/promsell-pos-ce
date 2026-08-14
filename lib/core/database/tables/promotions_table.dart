import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';

@DataClassName('PromotionData')
class Promotions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get type => text().withDefault(const Constant('PERCENT'))();
  RealColumn get value => real().withDefault(const Constant(0))();
  IntColumn get valueSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  RealColumn get minPurchaseAmount => real().withDefault(const Constant(0))();
  // Phase M (C1): INTEGER satang dual-write column for minPurchaseAmount.
  // `value` stays REAL for compatibility; `valueSatang` is populated only
  // when type=AMOUNT.
  IntColumn get minPurchaseAmountSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  DateTimeColumn get startDate => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
