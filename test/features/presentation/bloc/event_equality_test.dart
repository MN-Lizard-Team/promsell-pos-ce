import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('CartEvent equality', () {
    test('CartProductAdded', () {
      final a = CartProductAdded(tProduct, qty: 2);
      final b = CartProductAdded(tProduct, qty: 2);
      final c = CartProductAdded(tProduct, qty: 3);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartProductRemoved', () {
      const a = CartProductRemoved('p1');
      const b = CartProductRemoved('p1');
      const c = CartProductRemoved('p2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartItemQtyChanged', () {
      const a = CartItemQtyChanged(productId: 'p1', qty: 5);
      const b = CartItemQtyChanged(productId: 'p1', qty: 5);
      const c = CartItemQtyChanged(productId: 'p1', qty: 6);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartRestored', () {
      final a = CartRestored(items: [tCartItem]);
      final b = CartRestored(items: [tCartItem]);
      expect(a, equals(b));
    });

    test('CartItemDiscountChanged', () {
      const a = CartItemDiscountChanged(
        productId: 'p1',
        discountType: 'percent',
        discountValue: 10,
      );
      const b = CartItemDiscountChanged(
        productId: 'p1',
        discountType: 'percent',
        discountValue: 10,
      );
      const c = CartItemDiscountChanged(
        productId: 'p1',
        discountType: 'amount',
        discountValue: 10,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartDiscountChanged', () {
      const a = CartDiscountChanged(discountType: 'percent', discountValue: 10);
      const b = CartDiscountChanged(discountType: 'percent', discountValue: 10);
      const c = CartDiscountChanged(discountType: 'percent', discountValue: 20);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartNoteChanged', () {
      const a = CartNoteChanged('hello');
      const b = CartNoteChanged('hello');
      const c = CartNoteChanged('world');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartBarcodeScanned', () {
      const a = CartBarcodeScanned('123456');
      const b = CartBarcodeScanned('123456');
      const c = CartBarcodeScanned('789012');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartBulkItemsRemoved', () {
      const a = CartBulkItemsRemoved(['p1', 'p2']);
      const b = CartBulkItemsRemoved(['p1', 'p2']);
      const c = CartBulkItemsRemoved(['p2', 'p1']);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CartItemsReordered', () {
      const a = CartItemsReordered(['p1', 'p2']);
      const b = CartItemsReordered(['p1', 'p2']);
      expect(a, equals(b));
    });
  });

  group('CheckoutEvent equality', () {
    test('CheckoutConfirmed', () {
      const a = CheckoutConfirmed(
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );
      const b = CheckoutConfirmed(
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );
      const c = CheckoutConfirmed(
        paymentMethod: 'promptpay',
        vatMode: 'NONE',
        vatRate: 0,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CheckoutPaymentConfirmed', () {
      const a = CheckoutPaymentConfirmed(paymentReference: 'ref1');
      const b = CheckoutPaymentConfirmed(paymentReference: 'ref1');
      const c = CheckoutPaymentConfirmed(paymentReference: 'ref2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('DraftEvent equality', () {
    test('DraftSwitched', () {
      const a = DraftSwitched('d1');
      const b = DraftSwitched('d1');
      const c = DraftSwitched('d2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('DraftCreated', () {
      const a = DraftCreated(name: 'A');
      const b = DraftCreated(name: 'A');
      const c = DraftCreated(name: 'B');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('DraftDeleted', () {
      const a = DraftDeleted('d1');
      const b = DraftDeleted('d1');
      expect(a, equals(b));
    });

    test('DraftRenamed', () {
      const a = DraftRenamed(draftId: 'd1', name: 'New');
      const b = DraftRenamed(draftId: 'd1', name: 'New');
      const c = DraftRenamed(draftId: 'd1', name: 'Old');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('DraftAutoSaveRequested', () {
      const a = DraftAutoSaveRequested(CartState());
      const b = DraftAutoSaveRequested(CartState());
      expect(a, equals(b));
    });
  });

  group('ProductEvent equality', () {
    test('ProductAdded', () {
      const a = ProductAdded(name: 'A', price: 10, stock: 5);
      const b = ProductAdded(name: 'A', price: 10, stock: 5);
      const c = ProductAdded(name: 'B', price: 10, stock: 5);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('ProductUpdated', () {
      final a = ProductUpdated(tProduct);
      final b = ProductUpdated(tProduct);
      expect(a, equals(b));
    });

    test('ProductDeleted', () {
      const a = ProductDeleted('p1');
      const b = ProductDeleted('p1');
      const c = ProductDeleted('p2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('ProductSearchChanged', () {
      const a = ProductSearchChanged('coffee');
      const b = ProductSearchChanged('coffee');
      const c = ProductSearchChanged('tea');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('ProductCategoryFilterChanged', () {
      const a = ProductCategoryFilterChanged('Drinks');
      const b = ProductCategoryFilterChanged('Drinks');
      const c = ProductCategoryFilterChanged('Food');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('BarcodesBatchGenerated', () {
      const a = BarcodesBatchGenerated(prefix: 'T1');
      const b = BarcodesBatchGenerated(prefix: 'T1');
      const c = BarcodesBatchGenerated(prefix: 'T2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('ProductStockFilterChanged', () {
      const a = ProductStockFilterChanged(StockFilter.all);
      const b = ProductStockFilterChanged(StockFilter.all);
      const c = ProductStockFilterChanged(StockFilter.lowStock);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
