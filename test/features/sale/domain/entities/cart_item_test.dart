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
      expect(tCartItem.props, [tProduct, 2, null, null]);
    });
  });
}
