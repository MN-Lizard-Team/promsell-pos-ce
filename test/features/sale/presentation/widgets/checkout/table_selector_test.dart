import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/table_selector.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockTableBloc mockTableBloc;

  RestaurantTable table(
    String id,
    String name, {
    TableStatus status = TableStatus.available,
  }) {
    return RestaurantTable(
      id: id,
      name: name,
      status: status,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
  }

  setUp(() {
    mockTableBloc = MockTableBloc();
  });

  group('TableSelector', () {
    testWidgets('lists free tables only — occupied tables are not offered', (
      tester,
    ) async {
      when(() => mockTableBloc.state).thenReturn(
        TableState(
          tables: [
            table('t1', 'T1'),
            table('t2', 'T2', status: TableStatus.occupied),
            table('t3', 'T3'),
          ],
        ),
      );
      await tester.pumpApp(
        TableSelector(selectedTableId: null, onSelected: (_) {}),
        tableBloc: mockTableBloc,
      );

      await tester.tap(find.byKey(const Key(TestKeys.tableSelectorField)));
      await tester.pumpAndSettle();

      expect(find.text('T1'), findsOneWidget);
      expect(find.text('T3'), findsOneWidget);
      // Occupied by another open bill → must not be an option.
      expect(find.text('T2'), findsNothing);
    });

    testWidgets(
      'keeps the cart-bound occupied table selectable and selected while '
      'editing its own bill',
      (tester) async {
        when(() => mockTableBloc.state).thenReturn(
          TableState(
            tables: [
              table('t1', 'T1', status: TableStatus.occupied),
              table('t2', 'T2', status: TableStatus.occupied),
            ],
          ),
        );
        await tester.pumpApp(
          TableSelector(selectedTableId: 't2', onSelected: (_) {}),
          tableBloc: mockTableBloc,
        );
        // Selected value is visible in the closed field.
        expect(find.text('T2'), findsOneWidget);

        await tester.tap(find.byKey(const Key(TestKeys.tableSelectorField)));
        await tester.pumpAndSettle();

        // Still listed as an option (button display + menu row).
        expect(find.text('T2'), findsNWidgets(2));
        // Another bill's occupied table stays hidden.
        expect(find.text('T1'), findsNothing);
      },
    );
  });
}
