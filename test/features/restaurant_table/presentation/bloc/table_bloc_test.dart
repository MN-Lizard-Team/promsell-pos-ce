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

  final tTables = [
    RestaurantTable(
      id: 't1',
      name: 'Table 1',
      zone: 'Indoor',
      seats: 4,
      status: TableStatus.available,
      sortOrder: 0,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    RestaurantTable(
      id: 't2',
      name: 'Table 2',
      zone: 'Outdoor',
      seats: 2,
      status: TableStatus.occupied,
      sortOrder: 1,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  setUp(() {
    mockRepo = MockRestaurantTableRepository();
    registerFallbackValue(TableStatus.available);
    registerFallbackValue(tTables.first);
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
      'emits [loading, loaded] when TablesLoaded succeeds',
      build: () {
        when(() => mockRepo.getAllTables()).thenAnswer((_) async => tTables);
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const TablesLoaded()),
      expect: () => [
        const TableState(status: TableBlocStatus.loading),
        TableState(status: TableBlocStatus.loaded, tables: tTables),
      ],
    );

    blocTest<TableBloc, TableState>(
      'emits [loading, failure] when TablesLoaded fails',
      build: () {
        when(() => mockRepo.getAllTables()).thenThrow(Exception('db error'));
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
      'emits [saving, saved] when TableAdded succeeds',
      build: () {
        when(
          () => mockRepo.addTable(
            name: any(named: 'name'),
            zone: any(named: 'zone'),
            seats: any(named: 'seats'),
            sortOrder: any(named: 'sortOrder'),
          ),
        ).thenAnswer((_) async => 't3');
        when(() => mockRepo.getAllTables()).thenAnswer((_) async => tTables);
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const TableAdded(name: 'Table 3')),
      expect: () => [
        const TableState(status: TableBlocStatus.saving),
        TableState(status: TableBlocStatus.saved, tables: tTables),
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
        when(() => mockRepo.getAllTables()).thenAnswer((_) async => tTables);
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(TableUpdated(tTables.first)),
      expect: () => [
        const TableState(status: TableBlocStatus.saving),
        TableState(status: TableBlocStatus.saved, tables: tTables),
      ],
    );

    blocTest<TableBloc, TableState>(
      'emits [saving, saved] when TableDeleted succeeds',
      build: () {
        when(() => mockRepo.deleteTable(any())).thenAnswer((_) async {});
        when(() => mockRepo.getAllTables()).thenAnswer((_) async => tTables);
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const TableDeleted('t1')),
      expect: () => [
        const TableState(status: TableBlocStatus.saving),
        TableState(status: TableBlocStatus.saved, tables: tTables),
      ],
    );

    blocTest<TableBloc, TableState>(
      'emits [loaded] when TableStatusChanged succeeds',
      build: () {
        when(
          () => mockRepo.updateTableStatus(any(), any()),
        ).thenAnswer((_) async {});
        when(() => mockRepo.getAllTables()).thenAnswer((_) async => tTables);
        return TableBloc(mockRepo);
      },
      act: (bloc) => bloc.add(
        const TableStatusChanged(id: 't1', status: TableStatus.occupied),
      ),
      expect: () => [
        TableState(status: TableBlocStatus.initial, tables: tTables),
      ],
    );

    blocTest<TableBloc, TableState>(
      'emits [failure] when TableStatusChanged fails',
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
