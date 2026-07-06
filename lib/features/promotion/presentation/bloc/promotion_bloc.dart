import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_event.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_state.dart';

class _PromotionsUpdated extends PromotionEvent {
  const _PromotionsUpdated(this.promotions);
  final List<Promotion> promotions;
  @override
  List<Object?> get props => [promotions];
}

@injectable
class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  PromotionBloc(this._repository) : super(const PromotionState()) {
    on<PromotionsSubscribed>(_onSubscribed);
    on<_PromotionsUpdated>(_onPromotionsUpdated);
    on<PromotionAdded>(_onAdded);
    on<PromotionUpdated>(_onUpdated);
    on<PromotionDeleted>(_onDeleted);
    on<PromotionSearchChanged>(_onSearchChanged);
  }

  final PromotionRepository _repository;
  StreamSubscription<List<Promotion>>? _sub;

  Future<void> _onSubscribed(
    PromotionsSubscribed event,
    Emitter<PromotionState> emit,
  ) async {
    emit(state.copyWith(status: PromotionStatus.loading));
    await _sub?.cancel();
    _sub = _repository.watchAllPromotions().listen(
      (promotions) => add(_PromotionsUpdated(promotions)),
    );
  }

  void _onPromotionsUpdated(
    _PromotionsUpdated event,
    Emitter<PromotionState> emit,
  ) {
    emit(
      state.copyWith(
        status: PromotionStatus.success,
        promotions: event.promotions,
        errorMessage: null,
        saveStatus: PromotionSaveStatus.idle,
      ),
    );
  }

  Future<void> _onAdded(
    PromotionAdded event,
    Emitter<PromotionState> emit,
  ) async {
    emit(state.copyWith(saveStatus: PromotionSaveStatus.saving));
    try {
      await _repository.addPromotion(event.promotion);
      emit(state.copyWith(saveStatus: PromotionSaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: PromotionSaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdated(
    PromotionUpdated event,
    Emitter<PromotionState> emit,
  ) async {
    emit(state.copyWith(saveStatus: PromotionSaveStatus.saving));
    try {
      await _repository.updatePromotion(event.promotion);
      emit(state.copyWith(saveStatus: PromotionSaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: PromotionSaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    PromotionDeleted event,
    Emitter<PromotionState> emit,
  ) async {
    emit(state.copyWith(saveStatus: PromotionSaveStatus.saving));
    try {
      await _repository.deletePromotion(event.id);
      emit(state.copyWith(saveStatus: PromotionSaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: PromotionSaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchChanged(
    PromotionSearchChanged event,
    Emitter<PromotionState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
