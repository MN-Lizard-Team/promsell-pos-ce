import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';

void main() {
  final tProduct = Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(50),
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
      expect(draft.displayName, '');
    });

    test('displayName returns Draft when name is empty', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        name: '',
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.displayName, '');
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
      expect(draft.total, Money.fromDouble(100));
    });

    test('total with percent discount', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, Money.fromDouble(90));
    });

    test('total with amount discount', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 15,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, Money.fromDouble(85));
    });

    test('discountAmount clamps to raw total for amount discount', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 200,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, Money.zero);
      expect(draft.cartDiscountAmount, Money.fromDouble(50));
    });

    test('discountAmount is 0 when cartDiscountValue is 0', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 0,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.cartDiscountAmount, Money.zero);
      expect(draft.total, Money.fromDouble(100));
    });

    test('discountAmount is 0 when no discount type', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountValue: 10,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.cartDiscountAmount, Money.zero);
      expect(draft.total, Money.fromDouble(100));
    });

    test('supports equality', () {
      final draft1 = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1, lineId: 'line-1')],
        updatedAt: DateTime(2025, 1, 1),
      );
      final draft2 = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1, lineId: 'line-1')],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft1, draft2);
    });

    test('payableTotal subtracts promo (unlike legacy total)', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        promotionDiscountAmount: Money.fromDouble(20),
        updatedAt: DateTime(2025, 1, 1),
      );
      // total = items − cart disc only (100), does NOT subtract promo
      expect(draft.total, Money.fromDouble(100));
      // payableTotal uses SalePayableCalculator (promo applied)
      expect(draft.payableTotal(), Money.fromDouble(80));
    });
  });
}
