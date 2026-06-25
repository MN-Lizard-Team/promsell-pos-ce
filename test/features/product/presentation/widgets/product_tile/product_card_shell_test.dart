import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_card_shell.dart';

void main() {
  group('ProductCardShell', () {
    testWidgets('renders child inside card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProductCardShell(child: Text('Hello'))),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCardShell(
              onTap: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
