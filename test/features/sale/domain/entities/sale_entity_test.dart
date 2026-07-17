import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

void main() {
  group('SaleItem', () {
    final item = SaleItem(
      id: 'si1',
      saleId: 's1',
      productId: 'p1',
      productName: 'Coffee',
      price: Money.fromDouble(50),
      qty: 2,
      subtotal: Money.fromDouble(100),
    );

    test('has default values for optional fields', () {
      expect(item.discountAmount, Money.zero);
      expect(item.vatAmount, Money.zero);
      expect(item.version, 1);
      expect(item.updatedAt, isNull);
      expect(item.deletedAt, isNull);
      expect(item.deviceId, isNull);
    });

    test('supports value equality', () {
      final a = SaleItem(
        id: 'si1',
        saleId: 's1',
        productId: 'p1',
        productName: 'Coffee',
        price: Money.fromDouble(50),
        qty: 2,
        subtotal: Money.fromDouble(100),
      );
      expect(a, equals(item));
    });

    test('different items are not equal', () {
      final b = SaleItem(
        id: 'si2',
        saleId: 's1',
        productId: 'p1',
        productName: 'Coffee',
        price: Money.fromDouble(50),
        qty: 2,
        subtotal: Money.fromDouble(100),
      );
      expect(b, isNot(equals(item)));
    });
  });

  group('Sale', () {
    final sale = Sale(
      id: 's1',
      totalAmount: Money.fromDouble(200),
      paymentMethod: 'CASH',
      createdAt: DateTime(2025, 1, 1),
    );

    test('has default values for optional fields', () {
      expect(sale.status, 'COMPLETED');
      expect(sale.subtotalAmount, Money.zero);
      expect(sale.discountAmount, Money.zero);
      expect(sale.vatMode, 'NONE');
      expect(sale.vatRate, 0.0);
      expect(sale.items, isEmpty);
      expect(sale.receiptNumber, isNull);
    });

    test('isVoided is false for COMPLETED status', () {
      expect(sale.isVoided, isFalse);
    });

    test('isVoided is true for VOIDED status', () {
      final voided = Sale(
        id: 's1',
        totalAmount: Money.fromDouble(200),
        paymentMethod: 'CASH',
        status: 'VOIDED',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(voided.isVoided, isTrue);
    });

    test('supports value equality', () {
      final a = Sale(
        id: 's1',
        totalAmount: Money.fromDouble(200),
        paymentMethod: 'CASH',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(a, equals(sale));
    });

    test('with items and discount fields', () {
      final saleWithItems = Sale(
        id: 's2',
        totalAmount: Money.fromDouble(180),
        paymentMethod: 'PROMPTPAY',
        subtotalAmount: Money.fromDouble(200),
        discountType: 'PERCENT',
        discountValue: 10,
        discountAmount: Money.fromDouble(20),
        vatMode: 'EXCLUSIVE',
        vatRate: 7,
        vatAmount: Money.fromDouble(12.6),
        amountReceived: Money.fromDouble(200),
        changeAmount: Money.fromDouble(20),
        receiptNumber: 'R001',
        createdAt: DateTime(2025, 1, 1),
        items: [
          SaleItem(
            id: 'si1',
            saleId: 's2',
            productId: 'p1',
            productName: 'Coffee',
            price: Money.fromDouble(50),
            qty: 4,
            subtotal: Money.fromDouble(200),
          ),
        ],
      );

      expect(saleWithItems.items.length, 1);
      expect(saleWithItems.receiptNumber, 'R001');
      expect(saleWithItems.discountType, 'PERCENT');
      expect(saleWithItems.vatMode, 'EXCLUSIVE');
    });
  });
}
