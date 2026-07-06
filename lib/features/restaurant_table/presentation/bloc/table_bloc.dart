import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/repositories/restaurant_table_repository.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';

@lazySingleton
class TableBloc extends Bloc<TableEvent, TableState> {
  TableBloc(this._repository) : super(const TableState()) {
    on<TablesLoaded>(_onLoad);
    on<TableAdded>(_onAdd);
    on<TableUpdated>(_onUpdate);
    on<TableDeleted>(_onDelete);
    on<TableStatusChanged>(_onStatusChanged);
  }

  final RestaurantTableRepository _repository;

  Future<void> _onLoad(TablesLoaded event, Emitter<TableState> emit) async {
    emit(state.copyWith(status: TableBlocStatus.loading, errorMessage: null));
    try {
      final tables = await _repository.getAllTables();
      emit(state.copyWith(status: TableBlocStatus.loaded, tables: tables));
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

  Future<void> _onAdd(TableAdded event, Emitter<TableState> emit) async {
    emit(state.copyWith(status: TableBlocStatus.saving, errorMessage: null));
    try {
      await _repository.addTable(
        name: event.name,
        zone: event.zone,
        seats: event.seats,
        sortOrder: event.sortOrder,
      );
      final tables = await _repository.getAllTables();
      emit(state.copyWith(status: TableBlocStatus.saved, tables: tables));
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
      final tables = await _repository.getAllTables();
      emit(state.copyWith(status: TableBlocStatus.saved, tables: tables));
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
      final tables = await _repository.getAllTables();
      emit(state.copyWith(status: TableBlocStatus.saved, tables: tables));
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
    try {
      await _repository.updateTableStatus(event.id, event.status);
      final tables = await _repository.getAllTables();
      emit(state.copyWith(tables: tables));
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
}
