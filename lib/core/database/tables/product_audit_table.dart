import 'package:drift/drift.dart';

/// Audit trail for product changes (create, update, delete).
/// Tracks which field changed, old/new values, and timestamp.
@DataClassName('ProductAuditData')
class ProductAudits extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get action => text()();
  TextColumn get fieldName => text().nullable()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get changedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
