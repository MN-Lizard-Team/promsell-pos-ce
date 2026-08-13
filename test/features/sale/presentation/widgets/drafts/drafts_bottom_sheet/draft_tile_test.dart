import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_tile.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('DraftTile', () {
    testWidgets('renders active state', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final l10n = context.l10n;
            return DraftTile(
              id: 'd1',
              name: 'Table 1',
              itemCount: 3,
              total: 150.5,
              currency: '฿',
              isActive: true,
              tableId: 'T-5',
              previewItemName: 'Pad Thai',
              l10n: l10n,
              theme: theme,
              onSwitch: () {},
              onDelete: () {},
              onRename: (name) {},
              onPay: () {},
            );
          },
        ),
      );

      expect(find.textContaining('Table 1'), findsOneWidget);
      expect(find.textContaining('Active'), findsOneWidget);
      expect(find.textContaining('150.50'), findsOneWidget);
      expect(find.textContaining('T-5'), findsOneWidget);
      expect(find.textContaining('Pad Thai'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('sale_bill_tile_pay_d1')),
        findsOneWidget,
      );
    });

    testWidgets('renders untitled draft when name is empty', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final l10n = context.l10n;
            return DraftTile(
              id: 'd2',
              name: '',
              itemCount: 0,
              total: 0,
              currency: '฿',
              isActive: false,
              l10n: l10n,
              theme: theme,
              onSwitch: () {},
              onDelete: () {},
              onRename: (name) {},
            );
          },
        ),
      );

      // untitledDraft is product language "Untitled bill".
      expect(find.textContaining('Untitled bill'), findsOneWidget);
    });

    testWidgets('calls onSwitch when tapped', (tester) async {
      var switched = false;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final l10n = context.l10n;
            return DraftTile(
              id: 'd1',
              name: 'Table 1',
              itemCount: 3,
              total: 150.5,
              currency: '฿',
              isActive: true,
              l10n: l10n,
              theme: theme,
              onSwitch: () => switched = true,
              onDelete: () {},
              onRename: (name) {},
            );
          },
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(switched, isTrue);
    });

    testWidgets('shows rename dialog and calls onRename', (tester) async {
      var renamed = false;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final l10n = context.l10n;
            return DraftTile(
              id: 'd1',
              name: 'Old Name',
              itemCount: 3,
              total: 150.5,
              currency: '฿',
              isActive: true,
              l10n: l10n,
              theme: theme,
              onSwitch: () {},
              onDelete: () {},
              onRename: (name) => renamed = true,
            );
          },
        ),
      );

      await tester.tap(find.byKey(const ValueKey('sale_bill_tile_more_d1')));
      await tester.pumpAndSettle();
      // Bottom sheet actions (not PopupMenu).
      await tester.tap(find.byKey(const ValueKey('sale_bill_more_rename_d1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'New Name');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(renamed, isTrue);
    });

    testWidgets('shows delete confirmation dialog and calls onDelete', (
      tester,
    ) async {
      var deleted = false;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final l10n = context.l10n;
            return DraftTile(
              id: 'd1',
              name: 'Table 1',
              itemCount: 3,
              total: 150.5,
              currency: '฿',
              isActive: true,
              l10n: l10n,
              theme: theme,
              onSwitch: () {},
              onDelete: () => deleted = true,
              onRename: (name) {},
            );
          },
        ),
      );

      await tester.tap(find.byKey(const ValueKey('sale_bill_tile_more_d1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sale_bill_more_delete_d1')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });
  });
}
