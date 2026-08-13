import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_more_actions.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CartLineMoreActions', () {
    final product = Product(
      id: 'p1',
      name: 'Latte',
      price: Money.fromDouble(50),
      stock: 10,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final item = CartItem(product: product, qty: 2, lineId: 'line-test-1');

    testWidgets('renders ticket more chip with line-scoped key', (
      tester,
    ) async {
      await tester.pumpApp(
        CartLineMoreActions(
          enableDiscount: true,
          onDiscount: () {},
          onNote: () {},
          onDuplicate: () {},
          onRemove: () {},
          item: item,
          currency: '฿',
        ),
      );

      expect(
        find.byKey(const ValueKey('sale_cart_line_more_line-test-1')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('tap opens sheet with actions and product name', (
      tester,
    ) async {
      await tester.pumpApp(
        CartLineMoreActions(
          enableDiscount: true,
          onDiscount: () {},
          onNote: () {},
          onDuplicate: () {},
          onRemove: () {},
          item: item,
          currency: '฿',
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('sale_cart_line_more_line-test-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Latte'), findsWidgets);
      expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.note_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('delete action invokes onRemove', (tester) async {
      var removed = false;
      await tester.pumpApp(
        CartLineMoreActions(
          enableDiscount: false,
          onDiscount: () {},
          onNote: () {},
          onDuplicate: () {},
          onRemove: () => removed = true,
          item: item,
          currency: '฿',
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('sale_cart_line_more_line-test-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });
  });
}
