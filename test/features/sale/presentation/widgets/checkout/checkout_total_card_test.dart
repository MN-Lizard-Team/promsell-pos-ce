import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_total_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CheckoutTotalCard', () {
    testWidgets('hides when no discount/VAT/SC lines (due is sticky hero)', (
      tester,
    ) async {
      await tester.pumpApp(
        const CheckoutTotalCard(
          itemsSubtotal: 100,
          itemsDiscountTotal: 0,
          hasCartDiscount: false,
          cartDiscountAmount: 0,
          vatInfo: null,
          vatRate: 0,
          effectiveTotal: 100,
          currency: '฿',
        ),
      );

      // No second amount-due hero — empty breakdown.
      expect(
        find.byKey(const ValueKey('sale_checkout_breakdown')),
        findsNothing,
      );
      expect(find.textContaining('฿100'), findsNothing);
    });

    testWidgets('shows collapsible bill details when item discounts exist', (
      tester,
    ) async {
      await tester.pumpApp(
        const CheckoutTotalCard(
          itemsSubtotal: 200,
          itemsDiscountTotal: 20,
          hasCartDiscount: false,
          cartDiscountAmount: 0,
          vatInfo: null,
          vatRate: 0,
          effectiveTotal: 180,
          currency: '฿',
          initiallyExpanded: true,
        ),
      );

      expect(
        find.byKey(const ValueKey('sale_checkout_breakdown')),
        findsOneWidget,
      );
      expect(find.textContaining('200'), findsOneWidget);
      expect(find.textContaining('-'), findsOneWidget);
    });

    testWidgets('renders cart discount when expanded', (tester) async {
      await tester.pumpApp(
        const CheckoutTotalCard(
          itemsSubtotal: 200,
          itemsDiscountTotal: 0,
          hasCartDiscount: true,
          cartDiscountAmount: 30,
          vatInfo: null,
          vatRate: 0,
          effectiveTotal: 170,
          currency: '฿',
          initiallyExpanded: true,
        ),
      );

      expect(find.textContaining('-'), findsOneWidget);
    });
  });
}
