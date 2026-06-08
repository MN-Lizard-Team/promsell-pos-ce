import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_dotted_line_row.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('CartDottedLineRow', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpApp(
        const CartDottedLineRow(
          label: 'Subtotal',
          value: 100.0,
          currency: 'THB',
        ),
      );

      expect(find.text('Subtotal'), findsOneWidget);
    });

    testWidgets('renders value with currency', (tester) async {
      await tester.pumpApp(
        const CartDottedLineRow(
          label: 'Discount',
          value: 25.5,
          currency: 'THB',
        ),
      );

      expect(find.textContaining('THB'), findsOneWidget);
    });

    testWidgets('uses custom valueColor when provided', (tester) async {
      await tester.pumpApp(
        const CartDottedLineRow(
          label: 'Total',
          value: 100.0,
          currency: 'THB',
          valueColor: Colors.red,
        ),
      );

      expect(find.byType(CartDottedLineRow), findsOneWidget);
    });
  });
}
