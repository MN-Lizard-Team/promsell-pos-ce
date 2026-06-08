import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_qty_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('CartQtyButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpApp(
        CartQtyButton(icon: Icons.add, onPressed: () => pressed = true),
      );

      await tester.tap(find.byType(CartQtyButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpApp(CartQtyButton(icon: Icons.remove, onPressed: () {}));

      expect(find.byIcon(Icons.remove), findsOneWidget);
    });
  });
}
