import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';

/// Writes immutable business events inside the caller's transaction.
///
/// Actor identity is nullable for legacy/offline installs until an account
/// context exists; device identity is captured whenever the caller has it.
class TransactionEventWriter {
  const TransactionEventWriter(this._db);

  final AppDatabase _db;

  Future<void> append({
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    String? actorId,
    String? actorRole,
    String? deviceId,
    String? sessionId,
    String? correlationId,
    String? idempotencyKey,
    String? reason,
    String? beforeStatus,
    String? afterStatus,
    int? amountSatang,
    String? payloadJson,
    DateTime? occurredAt,
  }) async {
    await _db
        .into(_db.transactionEvents)
        .insert(
          TransactionEventsCompanion.insert(
            id: IdGenerator.newId(),
            aggregateType: aggregateType,
            aggregateId: aggregateId,
            eventType: eventType,
            actorId: Value(actorId),
            actorRole: Value(actorRole),
            deviceId: Value(deviceId),
            sessionId: Value(sessionId),
            correlationId: Value(correlationId),
            idempotencyKey: Value(idempotencyKey),
            reason: Value(reason),
            beforeStatus: Value(beforeStatus),
            afterStatus: Value(afterStatus),
            amountSatang: Value(amountSatang),
            payloadJson: Value(payloadJson),
            occurredAt: Value(occurredAt ?? DateTime.now()),
          ),
        );
  }
}
