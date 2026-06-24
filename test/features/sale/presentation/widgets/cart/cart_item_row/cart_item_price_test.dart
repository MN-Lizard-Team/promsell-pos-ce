import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_row/cart_item_price.dart';

void main() {
  group('CartItemDiscountBadge', () {
    testWidgets('renders discount amount with currency', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CartItemDiscountBadge(currency: '฿', discountAmount: 10.0),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
      expect(find.textContaining('฿10.00'), findsOneWidget);
    });
  });

  group('CartItemPriceColumn', () {
    final product = Product(
      id: 'p1',
      name: 'Coffee',
      price: 50,
      stock: 10,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    testWidgets('renders subtotal without discount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemPriceColumn(
              currency: '฿',
              item: CartItem(product: product, qty: 2),
              hasDiscount: false,
            ),
          ),
        ),
      );

      expect(find.byType(CartItemDiscountBadge), findsNothing);
    });

    testWidgets('renders discount badge and strikethrough when has discount', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartItemPriceColumn(
              currency: '฿',
              item: CartItem(
                product: product,
                qty: 2,
                discountType: 'PERCENT',
                discountValue: 10,
              ),
              hasDiscount: true,
            ),
          ),
        ),
      );

      expect(find.byType(CartItemDiscountBadge), findsOneWidget);
    });
  });

  group('CartItem', () {
    final product = Product(
      id: 'p1',
      name: 'Coffee',
      price: 50,
      stock: 10,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('rawSubtotal calculates correctly', () {
      final item = CartItem(product: product, qty: 3);
      expect(item.rawSubtotal, 150.0);
    });

    test('discountAmount is 0 when no discount', () {
      final item = CartItem(product: product, qty: 3);
      expect(item.discountAmount, 0.0);
    });

    test('discountAmount calculates for PERCENT', () {
      final item = CartItem(
        product: product,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      expect(item.discountAmount, 10.0);
    });

    test('discountAmount calculates for AMOUNT', () {
      final item = CartItem(
        product: product,
        qty: 2,
        discountType: 'AMOUNT',
        discountValue: 30,
      );
      expect(item.discountAmount, 30.0);
    });

    test('subtotal subtracts discount', () {
      final item = CartItem(
        product: product,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      expect(item.subtotal, 90.0);
    });

    test('clearDiscount removes discount', () {
      final item = CartItem(
        product: product,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      final cleared = item.clearDiscount();
      expect(cleared.discountType, isNull);
      expect(cleared.discountValue, isNull);
    });

    test('copyWith updates fields', () {
      final item = CartItem(product: product, qty: 1);
      final updated = item.copyWith(qty: 5);
      expect(updated.qty, 5);
      expect(updated.product, product);
    });
  });
}
