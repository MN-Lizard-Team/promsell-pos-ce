import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/summary_card.dart';

void main() {
  group('SummaryCard', () {
    testWidgets('displays title, value, and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SummaryCard(
              title: 'Net Revenue',
              value: 12500.50,
              currency: 'THB',
              subtitle: '42 sales',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Net Revenue'), findsOneWidget);
      expect(find.text('42 sales'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });
  });
}
