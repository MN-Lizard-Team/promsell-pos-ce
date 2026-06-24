import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

void main() {
  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final product2 = Product(
    id: 'p2',
    name: 'Tea',
    price: 30,
    stock: 5,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('CartState', () {
    test('isEmpty is true for default state', () {
      const state = CartState();
      expect(state.isEmpty, isTrue);
    });

    test('isEmpty is false when items exist', () {
      final state = CartState(items: [CartItem(product: product, qty: 1)]);
      expect(state.isEmpty, isFalse);
    });

    test('itemCount sums quantities', () {
      final state = CartState(
        items: [
          CartItem(product: product, qty: 2),
          CartItem(product: product2, qty: 3),
        ],
      );
      expect(state.itemCount, 5);
    });

    test('itemsSubtotal sums subtotals', () {
      final state = CartState(
        items: [
          CartItem(product: product, qty: 2),
          CartItem(product: product2, qty: 1),
        ],
      );
      expect(state.itemsSubtotal, 130.0);
    });

    test('cartDiscountAmount is 0 when no discount', () {
      final state = CartState(items: [CartItem(product: product, qty: 1)]);
      expect(state.cartDiscountAmount, 0.0);
    });

    test('cartDiscountAmount calculates for PERCENT', () {
      final state = CartState(
        items: [CartItem(product: product, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
      );
      expect(state.cartDiscountAmount, 10.0);
    });

    test('cartDiscountAmount calculates for AMOUNT', () {
      final state = CartState(
        items: [CartItem(product: product, qty: 2)],
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 30,
      );
      expect(state.cartDiscountAmount, 30.0);
    });

    test('total subtracts cart discount', () {
      final state = CartState(
        items: [CartItem(product: product, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
      );
      expect(state.total, 90.0);
    });

    test('hasCartDiscount is true when discount value > 0', () {
      const state = CartState(
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
      );
      expect(state.hasCartDiscount, isTrue);
    });

    test('hasCartDiscount is false when discount value is 0', () {
      const state = CartState(
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 0,
      );
      expect(state.hasCartDiscount, isFalse);
    });

    test('copyWith updates items', () {
      const state = CartState();
      final updated = state.copyWith(
        items: [CartItem(product: product, qty: 1)],
      );
      expect(updated.items.length, 1);
    });

    test('copyWith clears cartDiscountType when set to null', () {
      const state = CartState(
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
      );
      final updated = state.copyWith(
        cartDiscountType: null,
        cartDiscountValue: null,
      );
      expect(updated.cartDiscountType, isNull);
      expect(updated.cartDiscountValue, isNull);
    });

    test('copyWith clears stockWarning when set to null', () {
      const state = CartState(stockWarning: 'Low stock');
      final updated = state.copyWith(stockWarning: null);
      expect(updated.stockWarning, isNull);
    });
  });
}
