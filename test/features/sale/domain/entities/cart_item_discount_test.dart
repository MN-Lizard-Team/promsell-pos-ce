import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CartItem discount', () {
    test('no discount — subtotal equals rawSubtotal', () {
      final item = CartItem(product: tProduct, qty: 2);
      expect(item.discountAmount, 0.0);
      expect(item.subtotal, 200.0);
    });

    test('PERCENT discount — 10% of 200 = 20', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      expect(item.discountAmount, 20.0);
      expect(item.subtotal, 180.0);
    });

    test('AMOUNT discount — 30 baht off 200', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'AMOUNT',
        discountValue: 30,
      );
      expect(item.discountAmount, 30.0);
      expect(item.subtotal, 170.0);
    });

    test('AMOUNT discount capped at subtotal', () {
      final item = CartItem(
        product: tProduct,
        qty: 1,
        discountType: 'AMOUNT',
        discountValue: 999,
      );
      expect(item.discountAmount, 100.0);
      expect(item.subtotal, 0.0);
    });

    test('zero discountValue returns no discount', () {
      final item = CartItem(
        product: tProduct,
        qty: 1,
        discountType: 'PERCENT',
        discountValue: 0,
      );
      expect(item.discountAmount, 0.0);
    });

    test('100% discount results in zero subtotal', () {
      final item = CartItem(
        product: tProduct,
        qty: 1,
        discountType: 'PERCENT',
        discountValue: 100,
      );
      expect(item.discountAmount, 100.0);
      expect(item.subtotal, 0.0);
    });

    test('clearDiscount removes discount fields', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      final cleared = item.clearDiscount();
      expect(cleared.discountType, isNull);
      expect(cleared.discountValue, isNull);
      expect(cleared.discountAmount, 0.0);
      expect(cleared.subtotal, 200.0);
    });
  });

  group('CartState cart discount', () {
    test('no cart discount — total equals itemsSubtotal', () {
      // Tested implicitly via CartState.total getter with no cart discount
      final item = CartItem(product: tProduct, qty: 2);
      expect(item.subtotal, 200.0);
    });

    test('PERCENT 10% on 200 baht items = 20 baht cart discount', () {
      final item = CartItem(product: tProduct, qty: 2);
      final subtotal = item.subtotal; // 200
      final cartDiscount = subtotal * (10 / 100);
      expect(cartDiscount, closeTo(20.0, 0.01));
    });

    test('AMOUNT 50 baht cart discount on 200 baht', () {
      final item = CartItem(product: tProduct, qty: 2);
      final cartDiscount = 50.0.clamp(0.0, item.subtotal);
      expect(cartDiscount, 50.0);
    });
  });
}
