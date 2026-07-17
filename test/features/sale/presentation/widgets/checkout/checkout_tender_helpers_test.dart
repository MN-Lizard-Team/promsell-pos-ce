import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_tender_helpers.dart';

void main() {
  test('single tender uses method and full amount', () {
    final lines = CheckoutTenderHelpers.buildTenders(
      splitTender: false,
      method: 'cash',
      payableTotal: Money.fromDouble(100),
      reference: 'r1',
      splitCashText: '',
    );
    expect(lines, hasLength(1));
    expect(lines.single.method, 'cash');
    expect(lines.single.amount, Money.fromDouble(100));
    expect(lines.single.reference, 'r1');
  });

  test('split tender splits cash and remainder', () {
    final lines = CheckoutTenderHelpers.buildTenders(
      splitTender: true,
      method: 'promptpay',
      payableTotal: Money.fromDouble(100),
      reference: 'ref',
      splitCashText: '40',
    );
    expect(lines, hasLength(2));
    expect(lines[0].method, 'cash');
    expect(lines[0].amount, Money.fromDouble(40));
    expect(lines[1].method, 'promptpay');
    expect(lines[1].amount, Money.fromDouble(60));
    expect(lines[1].reference, 'ref');
  });

  test('quickAmounts includes total and rounded options', () {
    final q = CheckoutTenderHelpers.quickAmounts(87);
    expect(q.first, 87);
    expect(q, contains(90));
  });
}
