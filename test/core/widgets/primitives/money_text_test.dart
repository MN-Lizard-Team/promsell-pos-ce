import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

void main() {
  group('MoneyText', () {
    testWidgets('renders currency and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MoneyText(value: 99.5, currency: '฿')),
        ),
      );

      expect(find.text('฿99.50'), findsOneWidget);
    });

    testWidgets('renders with custom style and color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoneyText(
              value: 1500,
              currency: '\$',
              style: TextStyle(fontSize: 20),
              color: Colors.red,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.color, Colors.red);
      expect(text.style?.fontSize, 20);
    });

    testWidgets('renders negative value with minus', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MoneyText(value: -50.25, currency: '฿')),
        ),
      );

      expect(find.text('฿-50.25'), findsOneWidget);
    });

    testWidgets('renders zero value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MoneyText(value: 0, currency: '฿')),
        ),
      );

      expect(find.text('฿0.00'), findsOneWidget);
    });
  });
}
