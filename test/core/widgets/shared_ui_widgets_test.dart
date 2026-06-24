import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

void main() {
  testWidgets('MoneyText formats currency with two decimals', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MoneyText(value: 125.5, currency: '฿')),
      ),
    );

    expect(find.text('฿125.50'), findsOneWidget);
  });

  testWidgets('AppEmptyState renders title and optional message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products',
            message: 'Add a product to start selling',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.text('No products'), findsOneWidget);
    expect(find.text('Add a product to start selling'), findsOneWidget);
  });

  testWidgets('AppEmptyState hides message in compact height', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 120,
            child: AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Tap a product to add to cart',
              message: 'This copy should be hidden when compact',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tap a product to add to cart'), findsOneWidget);
    expect(find.text('This copy should be hidden when compact'), findsNothing);
  });

  testWidgets('AppEmptyState fits in very compact height', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 96,
            child: AppEmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Tap a product to add to cart',
              message: 'This copy should be hidden when very compact',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Tap a product to add to cart'), findsOneWidget);
    expect(
      find.text('This copy should be hidden when very compact'),
      findsNothing,
    );
  });
}
