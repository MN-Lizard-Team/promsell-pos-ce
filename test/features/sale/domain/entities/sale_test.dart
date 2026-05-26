import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('SaleItem', () {
    test('supports value equality', () {
      final a = tSaleItem;
      final b = SaleItem(
        id: 1,
        saleId: 1,
        productId: 1,
        productName: 'Test Product',
        price: 100.0,
        qty: 2,
        subtotal: 200.0,
      );
      expect(a, equals(b));
    });

    test('props contains all fields', () {
      expect(tSaleItem.props.length, 7);
    });
  });

  group('Sale', () {
    test('supports value equality', () {
      final a = tSale;
      final b = Sale(
        id: 1,
        totalAmount: 200.0,
        paymentMethod: 'cash',
        amountReceived: 500.0,
        changeAmount: 300.0,
        note: null,
        createdAt: tNow,
        items: [tSaleItem],
      );
      expect(a, equals(b));
    });

    test('default items is empty list', () {
      final sale = Sale(
        id: 2,
        totalAmount: 100.0,
        paymentMethod: 'promptpay',
        createdAt: tNow,
      );
      expect(sale.items, isEmpty);
    });

    test('props contains all fields', () {
      expect(tSale.props.length, 8);
    });
  });
}
