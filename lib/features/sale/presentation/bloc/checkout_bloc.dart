import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';

@lazySingleton
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required CreateSale createSale,
    required CartBloc cartBloc,
    required DraftBloc draftBloc,
  }) : _createSale = createSale,
       _cartBloc = cartBloc,
       _draftBloc = draftBloc,
       super(const CheckoutState()) {
    on<CheckoutConfirmed>(_onConfirmed);
    on<CheckoutPaymentConfirmed>(_onPaymentConfirmed);
    on<CheckoutPaymentCancelled>(_onPaymentCancelled);
    on<CheckoutReset>(_onReset);
  }

  final CreateSale _createSale;
  final CartBloc _cartBloc;
  final DraftBloc _draftBloc;

  CheckoutConfirmed? _pendingSaleEvent;

  Future<void> _onConfirmed(
    CheckoutConfirmed event,
    Emitter<CheckoutState> emit,
  ) async {
    if (_cartBloc.state.isEmpty) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: 'Cart is empty',
        ),
      );
      return;
    }

    if (event.paymentMethod == 'promptpay') {
      _pendingSaleEvent = event;
      emit(
        state.copyWith(
          status: CheckoutStatus.waitingPayment,
          errorMessage: null,
        ),
      );
      return;
    }

    await _completeSale(
      emit,
      paymentMethod: event.paymentMethod,
      vatMode: event.vatMode,
      vatRate: event.vatRate,
      cartDiscountType: event.cartDiscountType,
      cartDiscountValue: event.cartDiscountValue,
      cartDiscountAmount: event.cartDiscountAmount,
      amountReceived: event.amountReceived,
      changeAmount: event.changeAmount,
      note: event.note,
      paymentReference: event.paymentReference,
    );
  }

  Future<void> _onPaymentConfirmed(
    CheckoutPaymentConfirmed event,
    Emitter<CheckoutState> emit,
  ) async {
    final pending = _pendingSaleEvent;
    if (pending == null) return;
    _pendingSaleEvent = null;

    await _completeSale(
      emit,
      paymentMethod: pending.paymentMethod,
      vatMode: pending.vatMode,
      vatRate: pending.vatRate,
      cartDiscountType: pending.cartDiscountType,
      cartDiscountValue: pending.cartDiscountValue,
      cartDiscountAmount: pending.cartDiscountAmount,
      amountReceived: pending.amountReceived,
      changeAmount: pending.changeAmount,
      note: pending.note,
      paymentReference: event.paymentReference ?? pending.paymentReference,
      sendingBankCode: event.sendingBankCode,
    );
  }

  void _onPaymentCancelled(
    CheckoutPaymentCancelled event,
    Emitter<CheckoutState> emit,
  ) {
    _pendingSaleEvent = null;
    emit(state.copyWith(status: CheckoutStatus.idle, errorMessage: null));
  }

  void _onReset(CheckoutReset event, Emitter<CheckoutState> emit) {
    _pendingSaleEvent = null;
    _cartBloc.add(const CartCleared());
    emit(const CheckoutState());
  }

  Future<void> _completeSale(
    Emitter<CheckoutState> emit, {
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    double? cartDiscountAmount,
    double? amountReceived,
    double? changeAmount,
    String? note,
    String? paymentReference,
    String? sendingBankCode,
  }) async {
    final cartState = _cartBloc.state;
    emit(state.copyWith(status: CheckoutStatus.processing, errorMessage: null));
    try {
      final sale = await _createSale(
        items: cartState.items,
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
      );

      _draftBloc.add(const DraftRotated());

      emit(state.copyWith(status: CheckoutStatus.success, lastSale: sale));
    } catch (e) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _pendingSaleEvent = null;
    return super.close();
  }
}
