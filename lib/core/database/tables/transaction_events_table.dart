import 'package:drift/drift.dart';

/// Append-only business event history.
///
/// This table intentionally has no foreign key to operational rows: an audit
/// event must survive soft-delete, restore, and backup repair of its aggregate.
@DataClassName('TransactionEventData')
class TransactionEvents extends Table {
  TextColumn get id => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get eventType => text()();
  TextColumn get actorId => text().nullable()();
  TextColumn get actorRole => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get correlationId => text().nullable()();
  TextColumn get idempotencyKey => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get beforeStatus => text().nullable()();
  TextColumn get afterStatus => text().nullable()();
  IntColumn get amountSatang => integer().nullable()();
  TextColumn get payloadJson => text().nullable()();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
