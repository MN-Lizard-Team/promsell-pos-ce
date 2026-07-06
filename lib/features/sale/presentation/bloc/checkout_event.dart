import 'package:equatable/equatable.dart';

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
    this.orderType = 'dinein',
    this.orderChannel = 'walkin',
    this.externalOrderRef,
    this.tableId,
    this.serviceChargeRate = 0.0,
    this.serviceChargeAmount = 0.0,
  });
  final String paymentMethod;
  final String vatMode;
  final double vatRate;
  final String? cartDiscountType;
  final double? cartDiscountValue;
  final double? cartDiscountAmount;
  final double? amountReceived;
  final double? changeAmount;
  final String? note;
  final String? paymentReference;
  final String orderType;
  final String orderChannel;
  final String? externalOrderRef;
  final String? tableId;
  final double serviceChargeRate;
  final double serviceChargeAmount;
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
    orderType,
    orderChannel,
    externalOrderRef,
    tableId,
    serviceChargeRate,
    serviceChargeAmount,
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
