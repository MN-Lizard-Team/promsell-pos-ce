import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_summary_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DiscountPolicySummaryCard', () {
    testWidgets('renders title and badges', (tester) async {
      await tester.pumpApp(
        const DiscountPolicySummaryCard(
          enableItemDiscount: true,
          enableCartDiscount: false,
          defaultDiscountType: 'PERCENT',
          maxDiscountPercent: 50,
          maxDiscountAmount: 0,
          currency: 'THB',
        ),
      );

      expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
      expect(find.text('ON'), findsOneWidget);
      expect(find.text('OFF'), findsOneWidget);
    });

    testWidgets('renders percent label', (tester) async {
      await tester.pumpApp(
        const DiscountPolicySummaryCard(
          enableItemDiscount: true,
          enableCartDiscount: true,
          defaultDiscountType: 'PERCENT',
          maxDiscountPercent: 25,
          maxDiscountAmount: 100,
          currency: '฿',
        ),
      );

      expect(find.textContaining('25%'), findsOneWidget);
    });

    testWidgets('renders amount label with currency', (tester) async {
      await tester.pumpApp(
        const DiscountPolicySummaryCard(
          enableItemDiscount: false,
          enableCartDiscount: false,
          defaultDiscountType: 'AMOUNT',
          maxDiscountPercent: 100,
          maxDiscountAmount: 500,
          currency: '฿',
        ),
      );

      expect(find.textContaining('฿500'), findsOneWidget);
    });

    testWidgets('renders no limit for zero amount', (tester) async {
      await tester.pumpApp(
        const DiscountPolicySummaryCard(
          enableItemDiscount: false,
          enableCartDiscount: false,
          defaultDiscountType: 'AMOUNT',
          maxDiscountPercent: 100,
          maxDiscountAmount: 0,
          currency: '฿',
        ),
      );

      expect(find.textContaining('No limit'), findsOneWidget);
    });
  });
}
