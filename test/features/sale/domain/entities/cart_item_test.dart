import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CartItem', () {
    test('supports value equality', () {
      final a = CartItem(product: tProduct, qty: 2);
      final b = CartItem(product: tProduct, qty: 2);
      expect(a, equals(b));
    });

    test('subtotal is price * qty rounded to 2 decimals', () {
      expect(tCartItem.subtotal, 200.0);
    });

    test('subtotal with fractional prices', () {
      expect(tCartItem2.subtotal, 250.5);
    });

    test('copyWith updates qty', () {
      final updated = tCartItem.copyWith(qty: 5);
      expect(updated.qty, 5);
      expect(updated.product, tProduct);
    });

    test('copyWith updates product', () {
      final updated = tCartItem.copyWith(product: tProduct2);
      expect(updated.product, tProduct2);
      expect(updated.qty, tCartItem.qty);
    });

    test('props contains product and qty', () {
      expect(tCartItem.props, [tProduct, 2, null, null, null]);
    });

    test('rawSubtotal is price * qty', () {
      expect(tCartItem.rawSubtotal, 200.0);
    });

    test('discountAmount is 0 when no discount', () {
      expect(tCartItem.discountAmount, 0.0);
    });

    test('discountAmount for PERCENT type', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      expect(item.discountAmount, 20.0);
    });

    test('discountAmount for AMOUNT type', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'AMOUNT',
        discountValue: 30,
      );
      expect(item.discountAmount, 30.0);
    });

    test('discountAmount clamps AMOUNT to rawSubtotal', () {
      final item = CartItem(
        product: tProduct,
        qty: 1,
        discountType: 'AMOUNT',
        discountValue: 200,
      );
      expect(item.discountAmount, 100.0);
    });

    test('subtotal subtracts discount', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      expect(item.subtotal, 180.0);
    });

    test('discountAmount is 0 when discountValue is 0', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 0,
      );
      expect(item.discountAmount, 0.0);
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
      expect(cleared.qty, 2);
    });

    test('copyWith clears discountType when set to null', () {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      final updated = item.copyWith(discountType: null, discountValue: null);
      expect(updated.discountType, isNull);
      expect(updated.discountValue, isNull);
    });
  });
}
