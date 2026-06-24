import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';

void main() {
  final tProduct = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('DraftCart', () {
    test('displayName returns name when set', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        name: 'Table 1',
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.displayName, 'Table 1');
    });

    test('displayName returns Draft when name is null', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.displayName, 'Draft');
    });

    test('displayName returns Draft when name is empty', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        name: '',
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.displayName, 'Draft');
    });

    test('itemCount sums quantities', () {
      final draft = DraftCart(
        id: 'd1',
        items: [
          CartItem(product: tProduct, qty: 2),
          CartItem(product: tProduct, qty: 3),
        ],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.itemCount, 5);
    });

    test('total without discount', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, 100.0);
    });

    test('total with percent discount', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, 90.0);
    });

    test('total with amount discount', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 15,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, 85.0);
    });

    test('discountAmount clamps to raw total for amount discount', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 200,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, 0.0);
      expect(draft.discountAmount, 50.0);
    });

    test('discountAmount is 0 when cartDiscountValue is 0', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 0,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.discountAmount, 0.0);
      expect(draft.total, 100.0);
    });

    test('discountAmount is 0 when no discount type', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountValue: 10,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.discountAmount, 0.0);
      expect(draft.total, 100.0);
    });

    test('supports equality', () {
      final draft1 = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        updatedAt: DateTime(2025, 1, 1),
      );
      final draft2 = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft1, draft2);
    });
  });
}
