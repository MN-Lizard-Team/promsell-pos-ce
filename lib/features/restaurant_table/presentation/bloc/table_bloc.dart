import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/repositories/restaurant_table_repository.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';

@lazySingleton
class TableBloc extends Bloc<TableEvent, TableState> {
  TableBloc(this._repository) : super(const TableState()) {
    on<TablesLoaded>(_onLoad);
    on<TablesWatchRefreshed>(_onWatchRefreshed);
    on<TableAdded>(_onAdd);
    on<TableUpdated>(_onUpdate);
    on<TableDeleted>(_onDelete);
    on<TableStatusChanged>(_onStatusChanged);
  }

  final RestaurantTableRepository _repository;
  StreamSubscription<List<RestaurantTable>>? _tablesSubscription;

  /// Subscribes to the repository watch so effective statuses (occupied while
  /// an active draft cart binds the table) refresh automatically — including
  /// the atomic free-at-checkout, which needs no explicit reload.
  Future<void> _onLoad(TablesLoaded event, Emitter<TableState> emit) async {
    if (_tablesSubscription != null) return; // already watching — live updates
    emit(state.copyWith(status: TableBlocStatus.loading, errorMessage: null));
    try {
      await _tablesSubscription?.cancel();
      _tablesSubscription = _repository.watchTables().listen(
        (tables) => add(TablesWatchRefreshed(tables)),
        onError: (Object e, StackTrace stack) {
          AppLogger.error(
            'TableBloc.watchTables failed',
            error: e,
            stack: stack,
          );
        },
      );
    } catch (e, stack) {
      AppLogger.error('TableBloc._onLoad failed', error: e, stack: stack);
      emit(
        state.copyWith(
          status: TableBlocStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onWatchRefreshed(TablesWatchRefreshed event, Emitter<TableState> emit) {
    emit(
      state.copyWith(
        status: TableBlocStatus.loaded,
        tables: event.tables,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onAdd(TableAdded event, Emitter<TableState> emit) async {
    emit(state.copyWith(status: TableBlocStatus.saving, errorMessage: null));
    try {
      await _repository.addTable(
        name: event.name,
        zone: event.zone,
        seats: event.seats,
        sortOrder: event.sortOrder,
      );
      // The watch stream pushes refreshed tables; just flag success.
      emit(state.copyWith(status: TableBlocStatus.saved));
    } catch (e, stack) {
      AppLogger.error('TableBloc._onAdd failed', error: e, stack: stack);
      emit(
        state.copyWith(
          status: TableBlocStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdate(TableUpdated event, Emitter<TableState> emit) async {
    emit(state.copyWith(status: TableBlocStatus.saving, errorMessage: null));
    try {
      await _repository.updateTable(event.table);
      emit(state.copyWith(status: TableBlocStatus.saved));
    } catch (e, stack) {
      AppLogger.error('TableBloc._onUpdate failed', error: e, stack: stack);
      emit(
        state.copyWith(
          status: TableBlocStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDelete(TableDeleted event, Emitter<TableState> emit) async {
    emit(state.copyWith(status: TableBlocStatus.saving, errorMessage: null));
    try {
      await _repository.deleteTable(event.id);
      emit(state.copyWith(status: TableBlocStatus.saved));
    } catch (e, stack) {
      AppLogger.error('TableBloc._onDelete failed', error: e, stack: stack);
      emit(
        state.copyWith(
          status: TableBlocStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStatusChanged(
    TableStatusChanged event,
    Emitter<TableState> emit,
  ) async {
    // The stored column only holds manual available/reserved; occupancy is
    // derived from active draft carts and can never be set by hand.
    if (event.status == TableStatus.occupied) {
      emit(
        state.copyWith(
          status: TableBlocStatus.failure,
          errorMessage: 'tableOccupied',
        ),
      );
      return;
    }
    try {
      await _repository.updateTableStatus(event.id, event.status);
      emit(state.copyWith(status: TableBlocStatus.saved, errorMessage: null));
    } catch (e, stack) {
      AppLogger.error(
        'TableBloc._onStatusChanged failed',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          status: TableBlocStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _tablesSubscription?.cancel();
    _tablesSubscription = null;
    return super.close();
  }
}
