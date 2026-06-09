import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('SaleItem', () {
    test('supports value equality', () {
      final a = tSaleItem;
      const b = SaleItem(
        id: 'si-00000001-0001-0001-000000000001',
        saleId: 'sale-0001-0001-0001-000000000001',
        productId: 'prod-0001-0001-0001-000000000001',
        productName: 'Test Product',
        price: 100.0,
        qty: 2,
        subtotal: 200.0,
        discountAmount: 0.0,
        vatAmount: 0.0,
        version: 1,
      );
      expect(a, equals(b));
    });

    test('props contains all fields', () {
      expect(tSaleItem.props.length, 13);
    });
  });

  group('Sale', () {
    test('supports value equality', () {
      final a = tSale;
      final b = Sale(
        id: 'sale-0001-0001-0001-000000000001',
        totalAmount: 200.0,
        subtotalAmount: 200.0,
        discountType: null,
        discountValue: null,
        discountAmount: 0.0,
        vatMode: 'NONE',
        vatRate: 0.0,
        vatAmount: 0.0,
        paymentMethod: 'cash',
        amountReceived: 500.0,
        changeAmount: 300.0,
        note: null,
        paymentReference: null,
        sendingBankCode: null,
        createdAt: tNow,
        items: const [tSaleItem],
      );
      expect(a, equals(b));
    });

    test('default items is empty list', () {
      final sale = Sale(
        id: 'sale-0002-0002-0002-000000000002',
        totalAmount: 100.0,
        paymentMethod: 'promptpay',
        createdAt: tNow,
      );
      expect(sale.items, isEmpty);
    });

    test('props contains all fields', () {
      expect(tSale.props.length, 21);
    });
  });
}
