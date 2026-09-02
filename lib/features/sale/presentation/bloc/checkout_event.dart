import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutConfirmed extends CheckoutEvent {
  const CheckoutConfirmed({
    required this.paymentMethod,
    required this.vatMode,
    required this.vatRate,
    this.cartDiscountType,
    this.cartDiscountValue,
    this.cartDiscountAmount,
    this.amountReceived,
    this.changeAmount,
    this.note,
    this.paymentReference,
    this.payments,
    this.orderType = 'delivery',
    this.orderChannel = 'walkin',
    this.externalOrderRef,
    this.tableId,
    this.serviceChargeRate = 0.0,
    this.serviceChargeAmount = Money.zero,
    this.selectedItemIds,
  });
  final String paymentMethod;
  final String vatMode;
  final double vatRate;
  final String? cartDiscountType;
  final double? cartDiscountValue;
  final Money? cartDiscountAmount;
  final Money? amountReceived;
  final Money? changeAmount;
  final String? note;
  final String? paymentReference;
  final List<SalePayment>? payments;
  final String orderType;
  final String orderChannel;
  final String? externalOrderRef;
  final String? tableId;
  final double serviceChargeRate;
  final Money serviceChargeAmount;
  final List<String>? selectedItemIds;
  @override
  List<Object?> get props => [
    paymentMethod,
    vatMode,
    vatRate,
    cartDiscountType,
    cartDiscountValue,
    cartDiscountAmount,
    amountReceived,
    changeAmount,
    note,
    paymentReference,
    payments,
    orderType,
    orderChannel,
    externalOrderRef,
    tableId,
    serviceChargeRate,
    serviceChargeAmount,
    selectedItemIds,
  ];
}

class CheckoutPaymentConfirmed extends CheckoutEvent {
  const CheckoutPaymentConfirmed({this.paymentReference, this.sendingBankCode});
  final String? paymentReference;
  final String? sendingBankCode;
  @override
  List<Object?> get props => [paymentReference, sendingBankCode];
}

class CheckoutPaymentCancelled extends CheckoutEvent {
  const CheckoutPaymentCancelled();
}

class CheckoutReset extends CheckoutEvent {
  const CheckoutReset();
}
