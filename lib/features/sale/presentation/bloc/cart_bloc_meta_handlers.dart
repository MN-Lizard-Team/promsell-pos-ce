part of 'cart_bloc.dart';

/// Payment lock, notes, restaurant meta, customer.
mixin CartBlocMetaHandlers on Bloc<CartEvent, CartState> {
  bool rejectIfPaymentLocked(Emitter<CartState> emit);

  void onPaymentLockChanged(
    CartPaymentLockChanged event,
    Emitter<CartState> emit,
  ) {
    if (state.paymentLocked == event.locked) return;
    emit(state.copyWith(paymentLocked: event.locked, errorMessage: null));
  }

  void onNoteChanged(CartNoteChanged event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(note: event.note));
  }

  void onTableAssigned(CartTableAssigned event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(tableId: event.tableId));
  }

  void onGuestCountChanged(
    CartGuestCountChanged event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(guestCount: event.guestCount));
  }

  void onCustomerSet(CartCustomerSet event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(customerId: event.customerId));
  }

  void onOrderTypeChanged(CartOrderTypeChanged event, Emitter<CartState> emit) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(orderType: event.orderType));
  }

  void onOrderChannelChanged(
    CartOrderChannelChanged event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(orderChannel: event.orderChannel));
  }

  void onExternalOrderRefChanged(
    CartExternalOrderRefChanged event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(externalOrderRef: event.externalOrderRef));
  }

  void onServiceChargeRateChanged(
    CartServiceChargeRateChanged event,
    Emitter<CartState> emit,
  ) {
    if (rejectIfPaymentLocked(emit)) return;
    emit(state.copyWith(serviceChargeRate: event.rate));
  }
}
