import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_qty_stepper.dart';

void main() {
  group('CartQtyStepper', () {
    testWidgets('displays qty value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartQtyStepper(
              qty: 5,
              onDecrement: () {},
              onIncrement: () {},
              onQtyTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('calls onIncrement when + tapped', (tester) async {
      var incremented = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartQtyStepper(
              qty: 3,
              onDecrement: () {},
              onIncrement: () => incremented = true,
              onQtyTap: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(incremented, isTrue);
    });

    testWidgets('calls onDecrement when - tapped', (tester) async {
      var decremented = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartQtyStepper(
              qty: 3,
              onDecrement: () => decremented = true,
              onIncrement: () {},
              onQtyTap: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(decremented, isTrue);
    });

    testWidgets('calls onQtyTap when qty text tapped', (tester) async {
      var qtyTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartQtyStepper(
              qty: 3,
              onDecrement: () {},
              onIncrement: () {},
              onQtyTap: () => qtyTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();

      expect(qtyTapped, isTrue);
    });
  });
}
