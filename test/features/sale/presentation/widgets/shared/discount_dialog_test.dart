import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

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
          presetType: 'amount',
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
          presetType: 'amount',
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

    testWidgets('asSheet bill discount uses sheet chrome not AlertDialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [PosThemeExtension.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DiscountDialog(
              title: 'Bill',
              currency: '฿',
              initialType: 'PERCENT',
              onApply: (_, _) {},
              asSheet: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
      // Sheet uses [DiscountDialog.title] (not a hardcoded cart-only string).
      expect(find.text('Bill'), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_discount_value')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('bill_discount_type_percent')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('bill_discount_type_amount')),
        findsOneWidget,
      );
      expect(find.byType(SegmentedButton<String>), findsNothing);
      expect(find.byKey(const ValueKey('bill_discount_apply')), findsOneWidget);
    });

    testWidgets('showCartDiscount opens via PosBottomSheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [PosThemeExtension.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => DiscountDialog.showCartDiscount(
                    context,
                    title: 'Cart discount',
                    currency: '฿',
                    initialType: 'PERCENT',
                    onApply: (_, _) {},
                  ),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(DiscountDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const ValueKey('bill_discount_value')), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_discount_apply')), findsOneWidget);
    });

    testWidgets('showItemDiscount opens ticket sheet with product context', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [PosThemeExtension.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => DiscountDialog.showItemDiscount(
                    context,
                    title: 'Latte',
                    currency: '฿',
                    initialType: 'PERCENT',
                    onApply: (_, _) {},
                  ),
                  child: const Text('open item'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open item'));
      await tester.pumpAndSettle();

      expect(find.byType(DiscountDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.byKey(const ValueKey('discount_sheet_context')),
        findsOneWidget,
      );
      expect(find.text('Latte'), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_discount_value')), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_discount_apply')), findsOneWidget);
    });

    testWidgets('asSheet apply applies value and pops', (tester) async {
      String? appliedType;
      double? appliedValue;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [PosThemeExtension.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DiscountDialog(
              title: 'Bill',
              currency: '฿',
              initialType: 'PERCENT',
              asSheet: true,
              onApply: (t, v) {
                appliedType = t;
                appliedValue = v;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const ValueKey('bill_discount_value')),
        '15',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('bill_discount_apply')));
      await tester.pumpAndSettle();

      expect(appliedType, 'PERCENT');
      expect(appliedValue, 15);
    });
  });
}
