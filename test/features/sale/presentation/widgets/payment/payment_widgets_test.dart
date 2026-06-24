import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ChangePreview', () {
    testWidgets('shows change label when enough', (tester) async {
      await tester.pumpApp(
        const ChangePreview(change: 50, currency: '฿', visible: true),
      );

      expect(find.byIcon(Icons.price_check), findsOneWidget);
    });

    testWidgets('shows remaining label when not enough', (tester) async {
      await tester.pumpApp(
        const ChangePreview(change: -30, currency: '฿', visible: true),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('hides when visible is false', (tester) async {
      await tester.pumpApp(
        const ChangePreview(change: 50, currency: '฿', visible: false),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(animatedContainer.constraints?.maxHeight, 0);
    });
  });

  group('PaymentMethodCard', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpApp(
        PaymentMethodCard(
          icon: Icons.payments,
          label: 'Cash',
          selected: false,
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.payments), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        PaymentMethodCard(
          icon: Icons.payments,
          label: 'Cash',
          selected: true,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('PaymentTotalRow', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpApp(
        const PaymentTotalRow(label: 'Subtotal', value: 100, currency: '฿'),
      );

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.textContaining('100'), findsOneWidget);
    });

    testWidgets('renders negative value with minus sign', (tester) async {
      await tester.pumpApp(
        const PaymentTotalRow(label: 'Discount', value: -50, currency: '฿'),
      );

      expect(find.textContaining('-฿50'), findsOneWidget);
    });
  });
}
