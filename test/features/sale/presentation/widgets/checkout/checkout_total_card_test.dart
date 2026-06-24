import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_total_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CheckoutTotalCard', () {
    testWidgets('renders total amount with no discounts', (tester) async {
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

      expect(find.textContaining('฿100'), findsOneWidget);
    });

    testWidgets('renders subtotal when item discounts exist', (tester) async {
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
        ),
      );

      expect(find.textContaining('200'), findsOneWidget);
      expect(find.textContaining('-'), findsOneWidget);
    });

    testWidgets('renders cart discount when present', (tester) async {
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
        ),
      );

      expect(find.textContaining('-'), findsOneWidget);
    });
  });
}
