part of 'cart_bloc.dart';

/// Promotion set / recompute.
mixin CartBlocPromoHandlers on Bloc<CartEvent, CartState> {
  PromotionRepository get promotionRepo;

  bool rejectIfPaymentLocked(Emitter<CartState> emit);
  Money promoBase(CartState s);

  Future<void> onPromotionSet(
    CartPromotionSet event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    if (event.promotionId == null) {
      emit(
        state.copyWith(
          promotionId: null,
          promotionDiscountAmount: 0,
          errorMessage: null,
        ),
      );
      return;
    }
    try {
      final promo = await promotionRepo.getPromotionById(event.promotionId!);
      if (promo == null || !promo.isCurrentlyActive) {
        emit(
          state.copyWith(
            errorMessage: 'promotionNotFound',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final amount = promo.discountFor(promoBase(state));
      emit(
        state.copyWith(
          promotionId: promo.id,
          promotionDiscountAmount: amount.value,
          errorMessage: null,
        ),
      );
    } catch (e, st) {
      AppLogger.error('CartBloc.onPromotionSet failed', error: e, stack: st);
      emit(
        state.copyWith(
          errorMessage: 'promotionNotFound',
          errorNonce: state.errorNonce + 1,
        ),
      );
    }
  }

  Future<void> onPromotionRecompute(
    CartPromotionRecompute event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    final id = state.promotionId;
    if (id == null) return;
    try {
      final promo = await promotionRepo.getPromotionById(id);
      if (promo == null || !promo.isCurrentlyActive) {
        emit(
          state.copyWith(
            promotionId: null,
            promotionDiscountAmount: 0,
            errorMessage: 'promotionNotFound',
            errorNonce: state.errorNonce + 1,
          ),
        );
        return;
      }
      final amount = promo.discountFor(promoBase(state));
      if (amount.value == state.promotionDiscountAmount) return;
      emit(state.copyWith(promotionDiscountAmount: amount.value));
    } catch (e, st) {
      AppLogger.error(
        'CartBloc.onPromotionRecompute failed',
        error: e,
        stack: st,
      );
    }
  }
}
