import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/transaction_event_writer.dart';

import '../../helpers/fake_database.dart';

void main() {
  test('appends a complete immutable business event', () async {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    final writer = TransactionEventWriter(db);

    await writer.append(
      aggregateType: 'SALE',
      aggregateId: 'sale-1',
      eventType: 'SALE_VOIDED',
      deviceId: 'device-1',
      reason: 'Customer return',
      beforeStatus: 'COMPLETED',
      afterStatus: 'VOIDED',
      amountSatang: 12500,
      idempotencyKey: 'sale-1:void:1',
    );

    final rows = await db.select(db.transactionEvents).get();
    expect(rows, hasLength(1));
    expect(rows.single.aggregateType, 'SALE');
    expect(rows.single.aggregateId, 'sale-1');
    expect(rows.single.eventType, 'SALE_VOIDED');
    expect(rows.single.reason, 'Customer return');
    expect(rows.single.amountSatang, 12500);
    expect(rows.single.idempotencyKey, 'sale-1:void:1');
  });

  test('rejects a duplicate idempotency key', () async {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    final writer = TransactionEventWriter(db);

    final args = <String, Object?>{
      'aggregateType': 'SALE',
      'aggregateId': 'sale-1',
      'eventType': 'SALE_CREATED',
      'idempotencyKey': 'sale-1:create',
    };
    await writer.append(
      aggregateType: args['aggregateType']! as String,
      aggregateId: args['aggregateId']! as String,
      eventType: args['eventType']! as String,
      idempotencyKey: args['idempotencyKey']! as String,
    );

    expect(
      () => writer.append(
        aggregateType: 'SALE',
        aggregateId: 'sale-1',
        eventType: 'SALE_CREATED',
        idempotencyKey: 'sale-1:create',
      ),
      throwsA(isA<Exception>()),
    );
  });
}
