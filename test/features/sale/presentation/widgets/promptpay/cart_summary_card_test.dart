import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/cart_summary_card.dart';

void main() {
  final now = DateTime(2026, 1, 1);
  Product p(String id, String name) => Product(
    id: id,
    name: name,
    price: Money.fromDouble(10),
    stock: 5,
    isActive: true,
    trackStock: true,
    createdAt: now,
    updatedAt: now,
  );

  List<CartItem> items(int n) =>
      List.generate(n, (i) => CartItem(product: p('p$i', 'Item $i'), qty: 1));

  testWidgets('collapsed shows first 5 and expand control', (tester) async {
    var expanded = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CartSummaryCard(
            items: items(8),
            total: 80,
            currency: '฿',
            isExpanded: expanded,
            onToggleExpand: () => expanded = true,
            cartLabel: 'Cart',
            totalLabel: 'Total',
            showMoreLabel: 'Show more',
            showLessLabel: 'Show less',
          ),
        ),
      ),
    );
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 4'), findsOneWidget);
    expect(find.text('Item 5'), findsNothing);
    expect(find.text('Show more'), findsOneWidget);
    expect(find.textContaining('Cart'), findsWidgets);
    await tester.tap(find.text('Show more'));
    expect(expanded, isTrue);
  });

  testWidgets('expanded lists all items and show less', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CartSummaryCard(
            items: items(7),
            total: 70,
            currency: '฿',
            isExpanded: true,
            onToggleExpand: () {},
            cartLabel: 'Cart',
            totalLabel: 'Total',
            showMoreLabel: 'Show more',
            showLessLabel: 'Show less',
          ),
        ),
      ),
    );
    expect(find.text('Item 6'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);
  });
}
