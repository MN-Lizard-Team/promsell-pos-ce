import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late ReceiptNumberService service;

  setUp(() {
    db = createInMemoryDatabase();
    service = ReceiptNumberService(db);
  });

  tearDown(() => db.close());

  test('first call generates receipt with sequence 0001', () async {
    final receipt = await db.transaction(() => service.nextReceiptNumber());
    expect(receipt, matches(RegExp(r'^\d{6}-[A-Z0-9]{2}-0001$')));
  });

  test('second call on same day increments sequence', () async {
    final first = await db.transaction(() => service.nextReceiptNumber());
    final second = await db.transaction(() => service.nextReceiptNumber());

    final firstSeq = int.parse(first.split('-').last);
    final secondSeq = int.parse(second.split('-').last);
    expect(secondSeq, firstSeq + 1);
  });

  test('uses consistent device prefix across calls', () async {
    final first = await db.transaction(() => service.nextReceiptNumber());
    final second = await db.transaction(() => service.nextReceiptNumber());

    final firstPrefix = first.split('-')[1];
    final secondPrefix = second.split('-')[1];
    expect(secondPrefix, firstPrefix);
  });

  test('format matches YYMMDD-XX-NNNN', () async {
    final receipt = await db.transaction(() => service.nextReceiptNumber());
    expect(receipt, matches(RegExp(r'^\d{6}-[A-Z0-9]{2}-\d{4}$')));
  });

  test('sequence resets after date change', () async {
    // Generate first receipt for today
    await db.transaction(() => service.nextReceiptNumber());

    // Simulate a different date by writing a stale date
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'receiptSequenceDate',
            value: '2020-01-01',
          ),
        );

    final receipt = await db.transaction(() => service.nextReceiptNumber());
    final seq = int.parse(receipt.split('-').last);
    expect(seq, 1);
  });

  test('100 sequential calls produce unique receipt numbers', () async {
    final receipts = <String>[];
    for (var i = 0; i < 100; i++) {
      final r = await db.transaction(() => service.nextReceiptNumber());
      receipts.add(r);
    }
    expect(receipts.toSet().length, 100);
    // Last one should be 0100
    expect(receipts.last, endsWith('-0100'));
  });

  test('parseSeq extracts trailing sequence', () {
    expect(ReceiptNumberService.parseSeq('260715-A1-0042'), 42);
    expect(ReceiptNumberService.parseSeq(null), isNull);
    expect(ReceiptNumberService.parseSeq('bad'), isNull);
  });

  test('reseeds when settings lag behind existing sales', () async {
    // First number establishes prefix + seq 1.
    final first = await db.transaction(() => service.nextReceiptNumber());
    final parts = first.split('-');
    final dateKey = parts[0];
    final prefix = parts[1];

    // Insert a higher receipt as if restored from backup.
    await db
        .into(db.sales)
        .insert(
          SalesCompanion.insert(
            id: 'sale-restored',
            totalAmount: 100,
            paymentMethod: 'cash',
            receiptNumber: Value(
              ReceiptNumberService.formatReceiptNumber(
                dateKey: dateKey,
                devicePrefix: prefix,
                seq: 50,
              ),
            ),
          ),
        );

    // Settings still think we are at seq 1 — next must jump past 50.
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: 'receiptSequence', value: '1'),
        );

    final next = await db.transaction(() => service.nextReceiptNumber());
    expect(ReceiptNumberService.parseSeq(next), 51);
  });
}
