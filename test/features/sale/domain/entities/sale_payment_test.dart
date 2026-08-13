import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

void main() {
  test('SalePayment equality uses props', () {
    final a = SalePayment(
      method: 'cash',
      amount: Money.fromDouble(10),
      id: '1',
      saleId: 's',
      reference: 'r',
      sendingBankCode: '004',
      sortOrder: 1,
    );
    final b = SalePayment(
      method: 'cash',
      amount: Money.fromDouble(10),
      id: '1',
      saleId: 's',
      reference: 'r',
      sendingBankCode: '004',
      sortOrder: 1,
    );
    final c = SalePayment(method: 'card', amount: Money.fromDouble(10));
    expect(a, b);
    expect(a == c, isFalse);
    expect(a.props.length, 7);
  });
}
