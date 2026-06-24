import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DiscountDialog', () {
    testWidgets('renders with title and percent type by default', (
      tester,
    ) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Item Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
        ),
      );

      expect(find.text('Item Discount'), findsOneWidget);
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('shows preset chips when provided', (tester) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Cart Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
          presetValues: const [5, 10, 15],
        ),
      );

      expect(find.byType(ActionChip), findsNWidgets(3));
      expect(find.text('5%'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('15%'), findsOneWidget);
    });

    testWidgets('shows amount preset chips when presetType is AMOUNT', (
      tester,
    ) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Cart Discount',
          currency: '฿',
          initialType: 'AMOUNT',
          onApply: (_, _) {},
          presetValues: const [10, 20],
          presetType: 'AMOUNT',
        ),
      );

      expect(find.byType(ActionChip), findsNWidgets(2));
      expect(find.text('฿10.00'), findsOneWidget);
      expect(find.text('฿20.00'), findsOneWidget);
    });

    testWidgets('apply button is disabled when value is 0', (tester) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
        ),
      );

      final filledButton = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      expect(filledButton.onPressed, isNull);
    });

    testWidgets('shows clear button when onClear is provided', (tester) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
          onClear: () {},
        ),
      );

      expect(find.text('Clear discount'), findsOneWidget);
    });

    testWidgets('does not show clear button when onClear is null', (
      tester,
    ) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
        ),
      );

      expect(find.text('Clear discount'), findsNothing);
    });

    testWidgets('entering value enables apply button', (tester) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
        ),
      );

      await tester.enterText(find.byType(TextField), '10');
      await tester.pump();

      final filledButton = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );
      expect(filledButton.onPressed, isNotNull);
    });

    testWidgets('tapping preset chip updates text field', (tester) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
          presetValues: const [10],
        ),
      );

      await tester.tap(find.byType(ActionChip).first);
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '10');
    });

    testWidgets('tapping amount preset chip switches type to AMOUNT', (
      tester,
    ) async {
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
          presetValues: const [10],
          presetType: 'AMOUNT',
        ),
      );

      await tester.tap(find.byType(ActionChip).first);
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '10.00');
    });

    testWidgets('tapping apply calls onApply and pops', (tester) async {
      var applied = false;
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          initialValue: 10,
          onApply: (_, _) => applied = true,
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(applied, isTrue);
    });

    testWidgets('tapping clear calls onClear and pops', (tester) async {
      var cleared = false;
      await tester.pumpApp(
        DiscountDialog(
          title: 'Discount',
          currency: '฿',
          initialType: 'PERCENT',
          onApply: (_, _) {},
          onClear: () => cleared = true,
        ),
      );

      await tester.tap(find.text('Clear discount'));
      await tester.pumpAndSettle();

      expect(cleared, isTrue);
    });
  });
}
