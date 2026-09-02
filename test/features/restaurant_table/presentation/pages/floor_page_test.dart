import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/pages/floor_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../helpers/mocks.dart';

class _FakeDraftEvent extends Fake implements DraftEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeDraftEvent());
  });

  late MockTableBloc tableBloc;
  late MockDraftBloc draftBloc;

  final now = DateTime(2026, 1, 1);

  RestaurantTable table({
    required String id,
    required String name,
    required String zone,
    required TableStatus status,
  }) {
    return RestaurantTable(
      id: id,
      name: name,
      zone: zone,
      seats: 4,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget subject(List<RestaurantTable> tables) {
    when(
      () => tableBloc.state,
    ).thenReturn(TableState(status: TableBlocStatus.loaded, tables: tables));
    when(() => draftBloc.state).thenReturn(const DraftState());
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: FloorPage(tableBloc: tableBloc, draftBloc: draftBloc),
    );
  }

  setUp(() {
    tableBloc = MockTableBloc();
    draftBloc = MockDraftBloc();
  });

  testWidgets('groups tables by zone and displays localized statuses', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject([
        table(
          id: '1',
          name: 'Table 1',
          zone: 'Indoor',
          status: TableStatus.available,
        ),
        table(
          id: '2',
          name: 'Table 2',
          zone: 'Indoor',
          status: TableStatus.occupied,
        ),
        table(
          id: '3',
          name: 'Table 3',
          zone: 'Outdoor',
          status: TableStatus.reserved,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Indoor'), findsOneWidget);
    expect(find.text('Outdoor'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Occupied'), findsOneWidget);
    expect(find.text('Reserved'), findsOneWidget);
    verify(() => tableBloc.add(const TablesLoaded())).called(1);
  });

  testWidgets(
    'long press opens transfer dialog and dispatches transfer event',
    (tester) async {
      await tester.pumpWidget(
        subject([
          table(
            id: 'source',
            name: 'Table 1',
            zone: 'Indoor',
            status: TableStatus.occupied,
          ),
          table(
            id: 'target',
            name: 'Table 2',
            zone: 'Indoor',
            status: TableStatus.available,
          ),
          table(
            id: 'reserved',
            name: 'Table 3',
            zone: 'Indoor',
            status: TableStatus.reserved,
          ),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Table 1'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer table'), findsOneWidget);
      expect(find.text('Table 2'), findsAtLeastNWidgets(1));
      expect(find.text('Table 3'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Table 2'));
      await tester.pump();

      final event = verify(() => draftBloc.add(captureAny())).captured.single;
      expect(
        event,
        const DraftTransferRequested(
          sourceTableId: 'source',
          targetTableId: 'target',
        ),
      );
    },
  );
}
