import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/quick_edit_sheet.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    required QuickEditField field,
    String initialValue = '10',
    String? productName,
  }) async {
    await tester.pumpApp(
      QuickEditSheet(
        field: field,
        initialValue: initialValue,
        productName: productName,
      ),
      settingsCubit: mockSettingsCubit,
    );
  }

  group('QuickEditSheet', () {
    testWidgets('renders name field', (tester) async {
      await pumpSheet(
        tester,
        field: QuickEditField.name,
        initialValue: 'Coffee',
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders stock stepper', (tester) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      expect(find.byType(StockStepper), findsOneWidget);
    });

    testWidgets('renders price field with currency prefix', (tester) async {
      await pumpSheet(tester, field: QuickEditField.price, initialValue: '100');

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('฿'), findsOneWidget);
    });

    testWidgets('product name displayed when provided', (tester) async {
      await pumpSheet(
        tester,
        field: QuickEditField.name,
        initialValue: 'Coffee',
        productName: 'Coffee',
      );

      expect(find.text('Coffee'), findsAtLeast(1));
    });

    testWidgets('Save button disabled when name unchanged', (tester) async {
      await pumpSheet(
        tester,
        field: QuickEditField.name,
        initialValue: 'Coffee',
      );

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Save button disabled when name empty', (tester) async {
      await pumpSheet(
        tester,
        field: QuickEditField.name,
        initialValue: 'Coffee',
      );

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Save button enabled when name changed', (tester) async {
      await pumpSheet(
        tester,
        field: QuickEditField.name,
        initialValue: 'Coffee',
      );

      await tester.enterText(find.byType(TextField), 'Tea');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('Save button disabled when price negative', (tester) async {
      await pumpSheet(tester, field: QuickEditField.price, initialValue: '100');

      await tester.enterText(find.byType(TextField), '-5');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Save button enabled when price changed valid', (tester) async {
      await pumpSheet(tester, field: QuickEditField.price, initialValue: '100');

      await tester.enterText(find.byType(TextField), '150');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('stock Set mode — stepper increments', (tester) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      final stepper = tester.widget<StockStepper>(find.byType(StockStepper));
      expect(stepper.value, 11);
    });

    testWidgets('stock Set mode — stepper decrements', (tester) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pump();

      final stepper = tester.widget<StockStepper>(find.byType(StockStepper));
      expect(stepper.value, 9);
    });

    testWidgets('stock Adjust mode — segmented button switch', (tester) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      expect(find.byType(StockStepper), findsOneWidget);
      expect(find.text('Set'), findsOneWidget);
      expect(find.text('Adjust'), findsOneWidget);

      await tester.tap(find.text('Adjust'));
      await tester.pump();

      expect(find.byType(StockStepper), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('stock Adjust mode — add delta enables save', (tester) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      await tester.tap(find.text('Adjust'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('stock Adjust mode — subtract to negative disables save', (
      tester,
    ) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '3');

      await tester.tap(find.text('Adjust'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.remove).at(0));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '10');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Cancel button is present', (tester) async {
      await pumpSheet(
        tester,
        field: QuickEditField.name,
        initialValue: 'Coffee',
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('only one drag handle is present', (tester) async {
      await pumpSheet(
        tester,
        field: QuickEditField.name,
        initialValue: 'Coffee',
      );

      final dragHandles = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 36 &&
            widget.constraints?.maxHeight == 4,
      );
      expect(dragHandles, findsOneWidget);
    });

    testWidgets('price regex blocks non-numeric suffix', (tester) async {
      await pumpSheet(tester, field: QuickEditField.price, initialValue: '100');

      await tester.enterText(find.byType(TextField), '123abc');
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isNot(contains('abc')));
    });

    testWidgets('InlineStockInputDialog Save disabled when input empty', (
      tester,
    ) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      await tester.tap(find.text('10'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        '',
      );
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(FilledButton),
        ),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('stock Adjust mode — delta=0 shows error and disables save', (
      tester,
    ) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      await tester.tap(find.text('Adjust'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('stock Adjust mode — delta=0 shows error text', (tester) async {
      await pumpSheet(tester, field: QuickEditField.stock, initialValue: '10');

      await tester.tap(find.text('Adjust'));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data ?? '').isNotEmpty &&
              widget.style?.color != null,
        ),
        findsAtLeast(1),
      );
    });
  });
}
