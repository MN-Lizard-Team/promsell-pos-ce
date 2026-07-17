part of 'cart_bloc.dart';

/// Item/cart discounts via CartDiscountPolicy.
mixin CartBlocDiscountHandlers on Bloc<CartEvent, CartState> {
  SettingsRepository get settingsRepo;

  bool rejectIfPaymentLocked(Emitter<CartState> emit);
  void schedulePromoRecompute();

  Future<void> onItemDiscountChanged(
    CartItemDiscountChanged event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    final clamped = await clampDiscount(
      type: event.discountType,
      value: event.discountValue,
    );
    if (clamped == null) return;
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      if (matches) {
        return i.copyWith(discountType: clamped.$1, discountValue: clamped.$2);
      }
      return i;
    }).toList();
    emit(state.copyWith(items: updated));
    schedulePromoRecompute();
  }

  void onItemDiscountCleared(
    CartItemDiscountCleared event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
    final updated = state.items.map((i) {
      final matches = event.lineId != null
          ? i.lineId == event.lineId
          : i.product.id == event.productId;
      return matches ? i.clearDiscount() : i;
    }).toList();
    emit(state.copyWith(items: updated));
    schedulePromoRecompute();
  }

  Future<void> onCartDiscountChanged(
    CartDiscountChanged event,
    Emitter<CartState> emit,
  ) async {
    if (rejectIfPaymentLocked(emit)) return;
    final clamped = await clampDiscount(
      type: event.discountType,
      value: event.discountValue,
    );
    if (clamped == null) {
      emit(state.copyWith(cartDiscountType: null, cartDiscountValue: null));
      schedulePromoRecompute();
      return;
    }
    emit(
      state.copyWith(
        cartDiscountType: clamped.$1,
        cartDiscountValue: clamped.$2,
      ),
    );
    schedulePromoRecompute();
  }

  /// Enforces settings discount policy (not UI-only).
  /// Returns null when item/cart discounts are disabled for that type path.
  Future<(String, double)?> clampDiscount({
    required String type,
    required double value,
  }) async {
    try {
      final settings = await settingsRepo.load();
      return CartDiscountPolicy.clamp(
        settings: settings,
        type: type,
        value: value,
      );
    } catch (e, stack) {
      return CartDiscountPolicy.clampOrRaw(
        settings: null,
        type: type,
        value: value,
        loadError: e,
        stack: stack,
      );
    }
  }

  void onCartDiscountCleared(
    CartDiscountCleared event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(cartDiscountType: null, cartDiscountValue: null));
    schedulePromoRecompute();
  }
}
