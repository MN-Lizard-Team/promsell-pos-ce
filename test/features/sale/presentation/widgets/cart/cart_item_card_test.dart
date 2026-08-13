import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CartItemCard', () {
    final product = Product(
      id: 'p1',
      name: 'Test Product',
      price: Money.fromDouble(99),
      stock: 10,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final item = CartItem(product: product, qty: 2);

    testWidgets('renders product name', (tester) async {
      await tester.pumpApp(
        CartItemCard(
          item: item,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () {},
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('renders quantity', (tester) async {
      await tester.pumpApp(
        CartItemCard(
          item: item,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () {},
        ),
      );

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('long-press calls onLongPress', (tester) async {
      var longPressed = false;
      await tester.pumpApp(
        CartItemCard(
          item: item,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onLongPress: () => longPressed = true,
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () {},
        ),
      );

      await tester.longPress(find.text('Test Product'));
      await tester.pump();
      expect(longPressed, isTrue);
    });

    testWidgets('swipe end-to-start dismisses and calls onDelete', (
      tester,
    ) async {
      var deleted = false;
      await tester.pumpApp(
        CartItemCard(
          item: item,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () => deleted = true,
        ),
      );

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });

    testWidgets('shows product-deleted warning when isAvailable is false', (
      tester,
    ) async {
      final unavailableItem = CartItem(
        product: product,
        qty: 2,
        isAvailable: false,
      );
      await tester.pumpApp(
        CartItemCard(
          item: unavailableItem,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () {},
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Product deleted'), findsOneWidget);
    });

    testWidgets('does not show warning when isAvailable is true', (
      tester,
    ) async {
      await tester.pumpApp(
        CartItemCard(
          item: item,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () {},
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });
  });
}
