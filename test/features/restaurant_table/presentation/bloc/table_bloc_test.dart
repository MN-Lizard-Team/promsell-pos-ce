import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/repositories/restaurant_table_repository.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';

class MockRestaurantTableRepository extends Mock
    implements RestaurantTableRepository {}

void main() {
  late MockRestaurantTableRepository mockRepo;
  late StreamController<List<RestaurantTable>> watchController;

  final tTables = [
    RestaurantTable(
      id: 't1',
      name: 'Table 1',
      zone: 'Indoor',
      seats: 4,
      status: TableStatus.available,
      manualStatus: TableStatus.available,
      sortOrder: 0,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    RestaurantTable(
      id: 't2',
      name: 'Table 2',
      zone: 'Outdoor',
      seats: 2,
      // Effective occupancy is DERIVED (active cart bound) — the repository
      // watch emits it; the bloc never persists it.
      status: TableStatus.occupied,
      manualStatus: TableStatus.available,
      sortOrder: 1,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  setUp(() {
    mockRepo = MockRestaurantTableRepository();
    // Broadcast: safe to close with zero listeners (tests that never load).
    watchController = StreamController<List<RestaurantTable>>.broadcast();
    registerFallbackValue(TableStatus.available);
    registerFallbackValue(tTables.first);
    when(
      () => mockRepo.watchTables(),
    ).thenAnswer((_) => watchController.stream);
  });

  tearDown(() async {
    await watchController.close();
  });

  group('TableBloc', () {
    test('initial state is TableState with initial status', () {
      final bloc = TableBloc(mockRepo);
      expect(bloc.state.status, TableBlocStatus.initial);
      expect(bloc.state.tables, isEmpty);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    blocTest<TableBloc, TableState>(
      'emits [loading, loaded] when TablesLoaded subscribes and watch emits',
      build: () => TableBloc(mockRepo),
      act: (bloc) async {
        bloc.add(const TablesLoaded());
        // Wait until the subscription exists before pushing an emission.
        await untilCalled(() => mockRepo.watchTables());
        watchController.add(tTables);
      },
      expect: () => [
        const TableState(status: TableBlocStatus.loading),
        TableState(status: TableBlocStatus.loaded, tables: tTables),
      ],
    );

    blocTest<TableBloc, TableState>(
      'watch re-emission refreshes tables without a new TablesLoaded '
      '(live occupancy)',
      build: () => TableBloc(mockRepo),
      act: (bloc) async {
        bloc.add(const TablesLoaded());
        await untilCalled(() => mockRepo.watchTables());
        watchController.add(tTables);
        await Future<void>.delayed(Duration.zero);
        // A cart was opened/paid elsewhere in the app — same subscription.
        watchController.add([tTables.first]);
      },
      expect: () => [
        const TableState(status: TableBlocStatus.loading),
        TableState(status: TableBlocStatus.loaded, tables: tTables),
        TableState(status: TableBlocStatus.loaded, tables: [tTables.first]),
      ],
    );

    blocTest<TableBloc, TableState>(
      'emits [loading, failure] when subscribing to the watch throws',
      build: () {
        when(() => mockRepo.watchTables()).thenThrow(Exception('db error'));
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const TablesLoaded()),
      expect: () => [
        const TableState(status: TableBlocStatus.loading),
        isA<TableState>()
            .having((s) => s.status, 'status', TableBlocStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<TableBloc, TableState>(
      'TablesLoaded twice subscribes only once (live updates preserved)',
      build: () => TableBloc(mockRepo),
      act: (bloc) async {
        bloc.add(const TablesLoaded());
        await untilCalled(() => mockRepo.watchTables());
        bloc.add(const TablesLoaded());
        watchController.add(tTables);
      },
      expect: () => [
        const TableState(status: TableBlocStatus.loading),
        TableState(status: TableBlocStatus.loaded, tables: tTables),
      ],
      verify: (_) => verify(() => mockRepo.watchTables()).called(1),
    );

    blocTest<TableBloc, TableState>(
      'emits [saving, saved] when TableAdded succeeds (watch pushes rows)',
      build: () {
        when(
          () => mockRepo.addTable(
            name: any(named: 'name'),
            zone: any(named: 'zone'),
            seats: any(named: 'seats'),
            sortOrder: any(named: 'sortOrder'),
          ),
        ).thenAnswer((_) async => 't3');
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const TableAdded(name: 'Table 3')),
      expect: () => [
        const TableState(status: TableBlocStatus.saving),
        const TableState(status: TableBlocStatus.saved),
      ],
      verify: (_) {
        verify(
          () => mockRepo.addTable(
            name: 'Table 3',
            zone: null,
            seats: null,
            sortOrder: 0,
          ),
        ).called(1);
      },
    );

    blocTest<TableBloc, TableState>(
      'emits [saving, saved] when TableUpdated succeeds',
      build: () {
        when(() => mockRepo.updateTable(any())).thenAnswer((_) async {});
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(TableUpdated(tTables.first)),
      expect: () => [
        const TableState(status: TableBlocStatus.saving),
        const TableState(status: TableBlocStatus.saved),
      ],
    );

    blocTest<TableBloc, TableState>(
      'emits [saving, saved] when TableDeleted succeeds',
      build: () {
        when(() => mockRepo.deleteTable(any())).thenAnswer((_) async {});
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const TableDeleted('t1')),
      expect: () => [
        const TableState(status: TableBlocStatus.saving),
        const TableState(status: TableBlocStatus.saved),
      ],
    );

    blocTest<TableBloc, TableState>(
      'TableStatusChanged reserved persists via updateTableStatus',
      build: () {
        when(
          () => mockRepo.updateTableStatus(any(), any()),
        ).thenAnswer((_) async {});
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(
        const TableStatusChanged(id: 't1', status: TableStatus.reserved),
      ),
      expect: () => [const TableState(status: TableBlocStatus.saved)],
      verify: (_) {
        verify(
          () => mockRepo.updateTableStatus('t1', TableStatus.reserved),
        ).called(1);
      },
    );

    blocTest<TableBloc, TableState>(
      'TableStatusChanged available persists (toggle back)',
      build: () {
        when(
          () => mockRepo.updateTableStatus(any(), any()),
        ).thenAnswer((_) async {});
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(
        const TableStatusChanged(id: 't2', status: TableStatus.available),
      ),
      expect: () => [const TableState(status: TableBlocStatus.saved)],
      verify: (_) {
        verify(
          () => mockRepo.updateTableStatus('t2', TableStatus.available),
        ).called(1);
      },
    );

    blocTest<TableBloc, TableState>(
      'TableStatusChanged occupied is rejected — occupancy is derived',
      build: () => TableBloc(mockRepo),
      act: (bloc) => bloc.add(
        const TableStatusChanged(id: 't1', status: TableStatus.occupied),
      ),
      expect: () => [
        isA<TableState>()
            .having((s) => s.status, 'status', TableBlocStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'tableOccupied'),
      ],
      verify: (_) =>
          verifyNever(() => mockRepo.updateTableStatus(any(), any())),
    );

    blocTest<TableBloc, TableState>(
      'emits [failure] when updateTableStatus fails',
      build: () {
        when(
          () => mockRepo.updateTableStatus(any(), any()),
        ).thenThrow(Exception('db error'));
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(
        const TableStatusChanged(id: 't1', status: TableStatus.reserved),
      ),
      expect: () => [
        isA<TableState>()
            .having((s) => s.status, 'status', TableBlocStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });
}
