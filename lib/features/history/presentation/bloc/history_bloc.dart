import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';

class _HistorySalesUpdated extends HistoryEvent {
  const _HistorySalesUpdated(this.sales);
  final List<Sale> sales;
  @override
  List<Object?> get props => [sales];
}

class _HistoryError extends HistoryEvent {
  const _HistoryError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required WatchSaleHistory watchSaleHistory,
    required VoidSale voidSale,
  }) : _watchSaleHistory = watchSaleHistory,
       _voidSale = voidSale,
       super(const HistoryState()) {
    on<HistorySubscribed>(_onSubscribed);
    on<HistoryDateRangeChanged>(_onDateRangeChanged);
    on<HistorySearchChanged>(_onSearchChanged);
    on<SaleVoidRequested>(_onVoidRequested);
    on<_HistorySalesUpdated>(_onSalesUpdated);
    on<_HistoryError>(_onError);
  }

  final WatchSaleHistory _watchSaleHistory;
  final VoidSale _voidSale;
  StreamSubscription<List<Sale>>? _sub;

  void _startListening(DateTime? from, DateTime? to) {
    _sub?.cancel();
    _sub = _watchSaleHistory(from: from, to: to).listen(
      (sales) => add(_HistorySalesUpdated(sales)),
      onError: (Object e) => add(_HistoryError(e.toString())),
    );
  }

  void _onSubscribed(HistorySubscribed event, Emitter<HistoryState> emit) {
    emit(state.copyWith(status: HistoryStatus.loading, errorMessage: null));
    _startListening(state.from, state.to);
  }

  void _onDateRangeChanged(
    HistoryDateRangeChanged event,
    Emitter<HistoryState> emit,
  ) {
    emit(
      state.copyWith(
        status: HistoryStatus.loading,
        from: event.from,
        to: event.to,
        errorMessage: null,
      ),
    );
    _startListening(event.from, event.to);
  }

  void _onSearchChanged(
    HistorySearchChanged event,
    Emitter<HistoryState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSalesUpdated(_HistorySalesUpdated event, Emitter<HistoryState> emit) {
    emit(
      state.copyWith(
        status: HistoryStatus.success,
        sales: event.sales,
        errorMessage: null,
      ),
    );
  }

  void _onError(_HistoryError event, Emitter<HistoryState> emit) {
    emit(
      state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onVoidRequested(
    SaleVoidRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.voiding));
    try {
      await _voidSale(event.saleId, reason: event.reason);
      emit(state.copyWith(status: HistoryStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
