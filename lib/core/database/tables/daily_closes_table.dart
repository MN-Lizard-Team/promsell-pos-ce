import 'package:drift/drift.dart';

@Deprecated('Scheduled for removal in v0.5.0 — schema v3 required')
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
  TextColumn get note => text().nullable()();
  DateTimeColumn get closedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
