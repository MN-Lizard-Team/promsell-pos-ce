import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/services/restaurant_table_name_resolver.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_tile.dart';

import '../../../../../../helpers/pump_app.dart';

/// In-memory [RestaurantTableNameResolver] — ids absent from the map behave
/// like deleted tables (resolve to null → short-id fallback).
class _FakeResolver implements RestaurantTableNameResolver {
  final Map<String, String> names;

  _FakeResolver([this.names = const {}]);

  @override
  Future<String?> resolve(String tableId) async => names[tableId.trim()];

  @override
  void invalidate() => names.clear();
}

Future<void> _pumpTile(
  WidgetTester tester, {
  String? tableId,
  String? name,
}) async {
  await tester.pumpApp(
    Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final l10n = context.l10n;
        return DraftTile(
          id: 'd1',
          name: name,
          itemCount: 3,
          total: 150.5,
          currency: '฿',
          isActive: true,
          tableId: tableId,
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
  // Flush the async table-name resolution.
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<RestaurantTableNameResolver>(
      _FakeResolver({'T-5': 'A-01'}),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('DraftTile', () {
    testWidgets('renders active state', (tester) async {
      await _pumpTile(tester, name: 'Table 1', tableId: 'T-5');

      expect(find.textContaining('Table 1'), findsOneWidget);
      expect(find.textContaining('Active'), findsOneWidget);
      expect(find.textContaining('150.50'), findsOneWidget);
      expect(find.textContaining('Pad Thai'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('sale_bill_tile_pay_d1')),
        findsOneWidget,
      );
    });

    testWidgets('shows resolved table name in chip', (tester) async {
      await _pumpTile(tester, name: 'Walk-in', tableId: 'T-5');

      expect(find.textContaining('A-01'), findsOneWidget);
      expect(find.textContaining('T-5'), findsNothing);
    });

    testWidgets('swaps raw table-id bill name for the resolved table name', (
      tester,
    ) async {
      // Bills parked against a table carry the raw id as their name.
      await _pumpTile(tester, name: 'T-5', tableId: 'T-5');

      expect(find.text('A-01'), findsOneWidget);
      expect(find.textContaining('Table A-01'), findsOneWidget);
    });

    testWidgets('falls back to short id while unresolved / table deleted', (
      tester,
    ) async {
      const uuid = '3f9c2a1e-88aa-4d0f-b6f3-a1b2c3d4e5f6';
      await _pumpTile(tester, name: 'Walk-in', tableId: uuid);

      expect(find.textContaining('3f9c2a1e'), findsOneWidget);
      expect(find.textContaining(uuid), findsNothing);
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
