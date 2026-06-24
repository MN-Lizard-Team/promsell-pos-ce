import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

void main() {
  group('MoneyText', () {
    testWidgets('renders currency + value with 2 decimals', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MoneyText(value: 99.5, currency: '฿')),
        ),
      );

      expect(find.text('฿99.50'), findsOneWidget);
    });

    testWidgets('renders 0 correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MoneyText(value: 0, currency: '\$')),
        ),
      );

      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('renders large numbers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MoneyText(value: 99999.99, currency: '฿')),
        ),
      );

      expect(find.text('฿99999.99'), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoneyText(value: 10, currency: '฿', color: Colors.red),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.color, Colors.red);
    });

    testWidgets('applies textAlign', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MoneyText(
                value: 10,
                currency: '฿',
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textAlign, TextAlign.right);
    });
  });
}
