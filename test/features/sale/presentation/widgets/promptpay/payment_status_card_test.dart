import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/payment_status_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('PaymentStatusCard', () {
    testWidgets('shows waiting state when no bank code', (tester) async {
      await tester.pumpApp(
        const PaymentStatusCard(
          sendingBankCode: null,
          bankName: null,
          verifiedLabel: 'Verified',
          waitingLabel: 'Waiting for payment',
        ),
      );

      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.text('Waiting for payment'), findsOneWidget);
    });

    testWidgets('shows verified state with bank code', (tester) async {
      await tester.pumpApp(
        const PaymentStatusCard(
          sendingBankCode: '004',
          bankName: 'KBank',
          verifiedLabel: 'Payment verified',
          waitingLabel: 'Waiting',
        ),
      );

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.textContaining('Payment verified'), findsOneWidget);
      expect(find.textContaining('KBank'), findsOneWidget);
    });

    testWidgets('shows verified without bank name when null', (tester) async {
      await tester.pumpApp(
        const PaymentStatusCard(
          sendingBankCode: '004',
          bankName: null,
          verifiedLabel: 'Verified',
          waitingLabel: 'Waiting',
        ),
      );

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });
  });
}
