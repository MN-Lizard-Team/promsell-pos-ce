import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';

/// Frozen cart fields at confirm time (all payment methods).
class _CartSnapshot {
  const _CartSnapshot({
    required this.items,
    this.customerId,
    this.promotionId,
    this.promotionDiscountAmount = 0,
    this.draftCartId,
    this.selectedItemIds,
  });

  final List<CartItem> items;
  final String? customerId;
  final String? promotionId;
  final double promotionDiscountAmount;

  /// Originating draft cart id captured at freeze (NOT read later) so the
  /// sale transaction deletes exactly THIS parked bill atomically — immune
  /// to draft switches while payment is in flight.
  final String? draftCartId;
  final List<String>? selectedItemIds;
}

@lazySingleton
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required CreateSale createSale,
    required CartBloc cartBloc,
    required DraftBloc draftBloc,
    required TableBloc tableBloc,
  }) : _createSale = createSale,
       _cartBloc = cartBloc,
       _draftBloc = draftBloc,
       _tableBloc = tableBloc,
       super(const CheckoutState()) {
    on<CheckoutConfirmed>(_onConfirmed);
    on<CheckoutPaymentConfirmed>(_onPaymentConfirmed);
    on<CheckoutPaymentCancelled>(_onPaymentCancelled);
    on<CheckoutReset>(_onReset);
  }

  final CreateSale _createSale;
  final CartBloc _cartBloc;
  final DraftBloc _draftBloc;
  final TableBloc _tableBloc;

  CheckoutConfirmed? _pendingSaleEvent;
  _CartSnapshot? _frozenCart;

  void _clearPending() {
    _pendingSaleEvent = null;
    _frozenCart = null;
    // Always dispatch unlock (idempotent) so failure paths and tests stay
    // consistent even when cart mock state is stale.
    _cartBloc.add(const CartPaymentLockChanged(false));
  }

  Future<void> _onConfirmed(
    CheckoutConfirmed event,
    Emitter<CheckoutState> emit,
  ) async {
    // Block re-entry while a sale is writing or PromptPay is already open.
    if (state.status == CheckoutStatus.processing ||
        state.status == CheckoutStatus.waitingPayment) {
      return;
    }

    if (_cartBloc.state.isEmpty) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'cartEmpty',
        ),
      );
      return;
    }

    // Snapshot live cart once, then lock immediately so queued mutations cannot
    // change lines after the cashier taps pay (Wave C).
    final cart = _cartBloc.state;
    if (cart.items.any((i) => !i.isAvailable)) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'productInactive',
        ),
      );
      return;
    }

    // Defense in depth: a dine-in table already claimed by ANOTHER active
    // draft bill cannot be sold again. The draft-side unique index keeps
    // saves honest; this keeps the sale itself off a taken table. The table
    // bound to this cart's own open draft stays confirmable (editing an
    // existing dine-in bill must keep working).
    final tableId = event.tableId;
    if (tableId != null && _isTableClaimedByOtherBill(tableId)) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'tableAlreadyBound',
        ),
      );
      return;
    }

    final frozenItems = cart.items
        .map(
          (i) => i.copyWith(
            product: i.product,
            qty: i.qty,
            selectedOptions: List.of(i.selectedOptions),
          ),
        )
        .toList(growable: false);
    _frozenCart = _CartSnapshot(
      items: frozenItems,
      customerId: cart.customerId,
      promotionId: cart.promotionId,
      promotionDiscountAmount: cart.promotionDiscountAmount,
      draftCartId: _draftBloc.state.activeDraftId,
      selectedItemIds: event.selectedItemIds,
    );
    _pendingSaleEvent = event;
    // Lock before waitingPayment / createSale so UI and draft guards engage.
    _cartBloc.add(const CartPaymentLockChanged(true));

    // Any PromptPay tender (full bill or split share) opens QR flow first.
    final needsPromptPay = _needsPromptPayQr(event);
    if (needsPromptPay) {
      emit(
        state.copyWith(
          status: CheckoutStatus.waitingPayment,
          errorMessage: null,
          promptPayAmount: _promptPayAmountFrom(event),
          frozenItems: frozenItems,
        ),
      );
      return;
    }

    final frozen = _frozenCart;
    await _completeSale(
      emit,
      paymentMethod: event.paymentMethod,
      payments: event.payments,
      vatMode: event.vatMode,
      vatRate: event.vatRate,
      cartDiscountType: event.cartDiscountType,
      cartDiscountValue: event.cartDiscountValue,
      cartDiscountAmount: event.cartDiscountAmount,
      amountReceived: event.amountReceived,
      changeAmount: event.changeAmount,
      note: event.note,
      paymentReference: event.paymentReference,
      orderType: event.orderType,
      orderChannel: event.orderChannel,
      externalOrderRef: event.externalOrderRef,
      tableId: event.tableId,
      serviceChargeRate: event.serviceChargeRate,
      serviceChargeAmount: event.serviceChargeAmount,
      cartSnapshot: frozen,
    );
  }

  /// True when [tableId] is effectively occupied by a draft cart other than
  /// this checkout's own open bill. Reads [TableBloc] effective-status state
  /// (live watch, no DB hit); the own-binding exemption compares against the
  /// active draft's persisted table. Unknown tables are not blocked here —
  /// downstream sale validation owns that case.
  bool _isTableClaimedByOtherBill(String tableId) {
    if (tableId == _draftBloc.state.loadedDraft?.tableId) return false;
    for (final table in _tableBloc.state.tables) {
      if (table.id == tableId) {
        return table.status == TableStatus.occupied;
      }
    }
    return false;
  }

  static bool _needsPromptPayQr(CheckoutConfirmed event) {
    if (event.paymentMethod == 'promptpay') return true;
    final pays = event.payments;
    if (pays == null || pays.isEmpty) return false;
    return pays.any((p) => p.method.trim().toLowerCase() == 'promptpay');
  }

  static double? _promptPayAmountFrom(CheckoutConfirmed event) {
    final pays = event.payments;
    if (pays == null || pays.isEmpty) return null;
    final pp = pays.where((p) => p.method.trim().toLowerCase() == 'promptpay');
    if (pp.isEmpty) return null;
    var sum = 0.0;
    for (final p in pp) {
      sum += p.amount.value;
    }
    return sum;
  }

  Future<void> _onPaymentConfirmed(
    CheckoutPaymentConfirmed event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state.status == CheckoutStatus.processing) return;
    final pending = _pendingSaleEvent;
    if (pending == null) return;
    final frozen = _frozenCart;
    _pendingSaleEvent = null;
    final ref = event.paymentReference ?? pending.paymentReference;
    // Stamp PromptPay tender line with slip ref when cashier confirms QR.
    final payments = pending.payments == null
        ? null
        : [
            for (final p in pending.payments!)
              p.method.trim().toLowerCase() == 'promptpay' &&
                      (ref != null && ref.isNotEmpty)
                  ? SalePayment(
                      method: p.method,
                      amount: p.amount,
                      reference: ref,
                      sendingBankCode:
                          event.sendingBankCode ?? p.sendingBankCode,
                      sortOrder: p.sortOrder,
                    )
                  : p,
          ];
    // Keep freeze until complete uses it, then clear.
    await _completeSale(
      emit,
      paymentMethod: pending.paymentMethod,
      payments: payments,
      vatMode: pending.vatMode,
      vatRate: pending.vatRate,
      cartDiscountType: pending.cartDiscountType,
      cartDiscountValue: pending.cartDiscountValue,
      cartDiscountAmount: pending.cartDiscountAmount,
      amountReceived: pending.amountReceived,
      changeAmount: pending.changeAmount,
      note: pending.note,
      paymentReference: ref,
      sendingBankCode: event.sendingBankCode,
      orderType: pending.orderType,
      orderChannel: pending.orderChannel,
      externalOrderRef: pending.externalOrderRef,
      tableId: pending.tableId,
      serviceChargeRate: pending.serviceChargeRate,
      serviceChargeAmount: pending.serviceChargeAmount,
      cartSnapshot: frozen,
    );
    _frozenCart = null;
  }

  void _onPaymentCancelled(
    CheckoutPaymentCancelled event,
    Emitter<CheckoutState> emit,
  ) {
    // Wave P1: never unlock mid-CreateSale — cancel only while waiting on QR.
    // Ignore cancel during processing (and idle/success/failure no-ops).
    if (state.status == CheckoutStatus.processing) return;
    if (state.status != CheckoutStatus.waitingPayment) return;

    _clearPending();
    emit(
      state.copyWith(
        status: CheckoutStatus.idle,
        errorMessage: null,
        promptPayAmount: null,
        frozenItems: null,
      ),
    );
  }

  void _onReset(CheckoutReset event, Emitter<CheckoutState> emit) {
    _clearPending();
    _cartBloc.add(const CartCleared(force: true));
    emit(const CheckoutState());
  }

  Future<void> _completeSale(
    Emitter<CheckoutState> emit, {
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    Money? cartDiscountAmount,
    Money? amountReceived,
    Money? changeAmount,
    String? note,
    String? paymentReference,
    String? sendingBankCode,
    List<SalePayment>? payments,
    String orderType = 'delivery',
    String orderChannel = 'walkin',
    String? externalOrderRef,
    String? tableId,
    double serviceChargeRate = 0.0,
    Money serviceChargeAmount = Money.zero,
    _CartSnapshot? cartSnapshot,
  }) async {
    // Money path must use confirm-time freeze — never fall back to live cart.
    if (cartSnapshot == null) {
      _clearPending();
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'saleError',
          frozenItems: null,
          promptPayAmount: null,
        ),
      );
      return;
    }
    final items = cartSnapshot.items;
    final customerId = cartSnapshot.customerId;
    final promotionId = cartSnapshot.promotionId;
    final promotionDiscountAmount = cartSnapshot.promotionDiscountAmount;

    emit(
      state.copyWith(
        status: CheckoutStatus.processing,
        errorMessage: null,
        frozenItems: items,
      ),
    );
    try {
      final sale = await _createSale(
        items: items,
        paymentMethod: paymentMethod,
        vatMode: vatMode,
        vatRate: vatRate,
        cartDiscountType: cartDiscountType,
        cartDiscountValue: cartDiscountValue,
        cartDiscountAmount: cartDiscountAmount,
        amountReceived: amountReceived,
        changeAmount: changeAmount,
        note: note,
        paymentReference: paymentReference,
        sendingBankCode: sendingBankCode,
        payments: payments,
        orderType: orderType,
        orderChannel: orderChannel,
        externalOrderRef: externalOrderRef,
        tableId: tableId,
        serviceChargeRate: serviceChargeRate,
        serviceChargeAmount: serviceChargeAmount,
        customerId: customerId,
        promotionId: promotionId,
        promotionDiscountAmount: Money.fromDouble(promotionDiscountAmount),
        originatingDraftCartId: cartSnapshot.draftCartId,
        selectedItemIds: cartSnapshot.selectedItemIds,
      );

      if (cartSnapshot.selectedItemIds == null) {
        _cartBloc.add(const CartCleared(force: true));
        _draftBloc.add(DraftRotated(soldDraftId: cartSnapshot.draftCartId));
      } else {
        final remainingItems = _cartBloc.state.items
            .where(
              (item) => !cartSnapshot.selectedItemIds!.contains(item.lineId),
            )
            .toList(growable: false);
        // CartRestored is a guarded user-facing event; unlock before enqueueing
        // it so the remaining lines survive partial checkout.
        _cartBloc.add(const CartPaymentLockChanged(false));
        _cartBloc.add(
          CartRestored.fromCartState(
            _cartBloc.state.copyWith(items: remainingItems),
          ),
        );
      }
      _clearPending();

      emit(state.copyWith(status: CheckoutStatus.success, lastSale: sale));
    } catch (e, stack) {
      AppLogger.error(
        'CheckoutBloc._onCheckoutStarted failed',
        error: e,
        stack: stack,
      );
      // Unlock cart + drop freeze so cashier can fix stock/day and retry.
      // Do not clear cart lines — merchant must correct and re-confirm.
      _clearPending();
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: _mapCheckoutError(e),
          frozenItems: null,
          promptPayAmount: null,
        ),
      );
    }
  }

  /// Stable keys for UI → l10n (never raw exception strings).
  static String _mapCheckoutError(Object e) {
    if (e is BusinessRuleError) {
      return switch (e.rule) {
        'InsufficientStock' => 'insufficientStock',
        'ProductInactive' => 'productInactive',
        'ProductNotAvailable' => 'productInactive',
        'SaleAlreadyVoided' => 'saleAlreadyVoided',
        'DayClosed' => 'dayClosed',
        'PaymentMismatch' => 'paymentMismatch',
        _ => e.rule,
      };
    }
    if (e is NotFoundError) {
      return switch (e.resource) {
        'Customer' => 'customerNotFound',
        'Promotion' => 'promotionNotFound',
        'Product' => 'productNotFound',
        'Sale' => 'saleNotFound',
        _ => 'notFound',
      };
    }
    if (e is ValidationError) return 'validationError';
    if (e is DatabaseError) return 'databaseError';
    return 'saleError';
  }

  @override
  Future<void> close() async {
    if (_pendingSaleEvent != null || _frozenCart != null) {
      _clearPending();
    }
    return super.close();
  }
}
