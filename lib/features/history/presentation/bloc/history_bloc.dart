import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/get_sale_history_page.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

class _HistorySalesUpdated extends HistoryEvent {
  const _HistorySalesUpdated(this.sales, this.generation);
  final List<Sale> sales;
  final int generation;
  @override
  List<Object?> get props => [sales, generation];
}

class _HistoryError extends HistoryEvent {
  const _HistoryError(this.message, this.generation);
  final String message;
  final int generation;
  @override
  List<Object?> get props => [message, generation];
}

abstract final class HistoryErrorKeys {
  static const saleAlreadyVoided = 'saleAlreadyVoided';
  static const dayClosed = 'dayClosed';
  static const saleNotFound = 'saleNotFound';
  static const generic = 'errorOccurred';
}

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    WatchSaleHistory? watchSaleHistory,
    GetSaleHistoryPage? getSaleHistoryPage,
    required VoidSale voidSale,
  }) : _watchSaleHistory = watchSaleHistory,
       _getSaleHistoryPage = getSaleHistoryPage,
       _voidSale = voidSale,
       super(const HistoryState()) {
    on<HistorySubscribed>(_onSubscribed);
    on<HistoryDateRangeChanged>(_onDateRangeChanged);
    on<HistoryLoadMoreRequested>(_onLoadMore);
    on<HistorySearchChanged>(_onSearchChanged);
    on<SaleVoidRequested>(_onVoidRequested);
    on<_HistorySalesUpdated>(_onSalesUpdated);
    on<_HistoryError>(_onError);
  }

  final WatchSaleHistory? _watchSaleHistory;
  final GetSaleHistoryPage? _getSaleHistoryPage;
  final VoidSale _voidSale;
  StreamSubscription<List<Sale>>? _sub;
  int _generation = 0;

  bool get _paged => _getSaleHistoryPage != null;

  Future<void> _onSubscribed(
    HistorySubscribed event,
    Emitter<HistoryState> emit,
  ) async {
    if (_paged) {
      final hasData = state.sales.isNotEmpty;
      emit(
        state.copyWith(
          status: hasData ? HistoryStatus.success : HistoryStatus.loading,
          errorMessage: null,
          isStale: hasData,
          nextCursor: null,
          isLoadingMore: false,
        ),
      );
      await _loadPage(emit, replace: true, generation: ++_generation);
      return;
    }

    final hasData = state.sales.isNotEmpty;
    emit(
      state.copyWith(
        status: hasData ? HistoryStatus.success : HistoryStatus.loading,
        errorMessage: null,
        isStale: hasData,
      ),
    );
    await _startListening(state.from, state.to);
  }

  Future<void> _onDateRangeChanged(
    HistoryDateRangeChanged event,
    Emitter<HistoryState> emit,
  ) async {
    if (_paged) {
      final generation = ++_generation;
      emit(
        state.copyWith(
          status: HistoryStatus.loading,
          sales: const [],
          from: event.from,
          to: event.to,
          errorMessage: null,
          isStale: false,
          totalCount: 0,
          nextCursor: null,
          isLoadingMore: false,
        ),
      );
      await _loadPage(emit, replace: true, generation: generation);
      return;
    }

    emit(
      state.copyWith(
        status: HistoryStatus.loading,
        from: event.from,
        to: event.to,
        errorMessage: null,
      ),
    );
    await _startListening(event.from, event.to);
  }

  Future<void> _onLoadMore(
    HistoryLoadMoreRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (!_paged || state.isLoadingMore || !state.hasMore) return;
    final generation = _generation;
    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    await _loadPage(emit, replace: false, generation: generation);
  }

  Future<void> _onSearchChanged(
    HistorySearchChanged event,
    Emitter<HistoryState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.searchQuery) return;
    if (!_paged) {
      emit(state.copyWith(searchQuery: query));
      return;
    }
    final generation = ++_generation;
    emit(
      state.copyWith(
        status: HistoryStatus.loading,
        searchQuery: query,
        sales: const [],
        errorMessage: null,
        isStale: false,
        totalCount: 0,
        nextCursor: null,
        isLoadingMore: false,
      ),
    );
    await _loadPage(emit, replace: true, generation: generation);
  }

  Future<void> _loadPage(
    Emitter<HistoryState> emit, {
    required bool replace,
    required int generation,
  }) async {
    final pageLoader = _getSaleHistoryPage;
    if (pageLoader == null) return;
    try {
      final page = await pageLoader(
        from: state.from,
        to: state.to,
        cursor: replace ? null : state.nextCursor,
        searchQuery: state.searchQuery,
      );
      if (generation != _generation || isClosed) return;
      final merged = replace
          ? page.sales
          : _mergeSales(state.sales, page.sales);
      emit(
        state.copyWith(
          status: HistoryStatus.success,
          sales: merged,
          errorMessage: null,
          isStale: false,
          totalCount: page.totalCount,
          nextCursor: page.nextCursor,
          isLoadingMore: false,
        ),
      );
    } catch (error, stack) {
      if (generation != _generation || isClosed) return;
      AppLogger.error(
        'HistoryBloc page load failed',
        error: error,
        stack: stack,
      );
      emit(
        state.copyWith(
          status: state.sales.isEmpty
              ? HistoryStatus.failure
              : HistoryStatus.success,
          errorMessage: _mapHistoryReadErrorKey(error),
          isStale: state.sales.isNotEmpty,
          isLoadingMore: false,
        ),
      );
    }
  }

  List<Sale> _mergeSales(List<Sale> current, List<Sale> incoming) {
    final byId = <String, Sale>{for (final sale in current) sale.id: sale};
    for (final sale in incoming) {
      byId[sale.id] = sale;
    }
    return byId.values.toList();
  }

  Future<void> _startListening(DateTime? from, DateTime? to) async {
    final generation = ++_generation;
    await _sub?.cancel();
    final watch = _watchSaleHistory;
    if (watch == null) return;
    _sub = watch(from: from, to: to).listen(
      (sales) => add(_HistorySalesUpdated(sales, generation)),
      onError: (Object error) =>
          add(_HistoryError(_mapHistoryReadErrorKey(error), generation)),
    );
  }

  void _onSalesUpdated(_HistorySalesUpdated event, Emitter<HistoryState> emit) {
    if (event.generation != _generation) return;
    emit(
      state.copyWith(
        status: HistoryStatus.success,
        sales: event.sales,
        errorMessage: null,
        isStale: false,
      ),
    );
  }

  void _onError(_HistoryError event, Emitter<HistoryState> emit) {
    if (event.generation != _generation) return;
    emit(
      state.copyWith(
        status: state.sales.isEmpty
            ? HistoryStatus.failure
            : HistoryStatus.success,
        errorMessage: event.message,
        isStale: state.sales.isNotEmpty,
      ),
    );
  }

  String _mapHistoryReadErrorKey(Object error) {
    AppLogger.warning('HistoryBloc history read failed', error: error);
    return HistoryErrorKeys.generic;
  }

  Future<void> _onVoidRequested(
    SaleVoidRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state.voidingSaleId != null) return;
    emit(state.copyWith(voidingSaleId: event.saleId, errorMessage: null));
    try {
      await _voidSale(event.saleId, reason: event.reason);
      emit(
        state.copyWith(
          voidingSaleId: null,
          status: HistoryStatus.success,
          errorMessage: null,
        ),
      );
      if (_paged) add(const HistorySubscribed());
    } catch (error, stack) {
      AppLogger.error(
        'HistoryBloc._onVoidRequested failed',
        error: error,
        stack: stack,
      );
      emit(
        state.copyWith(
          voidingSaleId: null,
          status: state.status,
          errorMessage: mapHistoryVoidErrorKey(error),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

String mapHistoryVoidErrorKey(Object e) {
  if (e is BusinessRuleError && e.rule == 'SaleAlreadyVoided') {
    return HistoryErrorKeys.saleAlreadyVoided;
  }
  if (e is BusinessRuleError && e.rule == 'DayClosed') {
    return HistoryErrorKeys.dayClosed;
  }
  if (e is NotFoundError) return HistoryErrorKeys.saleNotFound;
  return HistoryErrorKeys.generic;
}
