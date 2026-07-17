import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

class SaleItem extends Equatable {
  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.subtotal,
    this.discountAmount = Money.zero,
    this.vatAmount = Money.zero,
    this.note,
    this.selectedOptions = const [],
    this.updatedAt,
    this.deletedAt,
    this.version = 1,
    this.deviceId,
  });

  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final Money price;
  final int qty;
  final Money subtotal;
  final Money discountAmount;
  final Money vatAmount;
  final String? note;
  final List<SelectedProductOption> selectedOptions;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? deviceId;

  @override
  List<Object?> get props => [
    id,
    saleId,
    productId,
    productName,
    price,
    qty,
    subtotal,
    discountAmount,
    vatAmount,
    note,
    selectedOptions,
    updatedAt,
    deletedAt,
    version,
    deviceId,
  ];
}

class Sale extends Equatable {
  const Sale({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    this.receiptNumber,
    this.status = 'COMPLETED',
    this.subtotalAmount = Money.zero,
    this.discountType,
    this.discountValue,
    this.discountAmount = Money.zero,
    this.vatMode = 'NONE',
    this.vatRate = 0.0,
    this.vatAmount = Money.zero,
    this.orderType = 'delivery',
    this.orderChannel = 'walkin',
    this.externalOrderRef,
    this.tableId,
    this.serviceChargeRate = 0.0,
    this.serviceChargeAmount = Money.zero,
    this.customerId,
    this.promotionId,
    this.promotionDiscountAmount = Money.zero,
    this.amountReceived,
    this.changeAmount,
    this.note,
    this.paymentReference,
    this.sendingBankCode,
    this.voidedAt,
    this.voidReason,
    required this.createdAt,
    this.items = const [],
    this.payments = const [],
  });

  final String id;
  final String? receiptNumber;
  final String status;
  final Money subtotalAmount;
  final String? discountType;
  final double? discountValue; // Can be % or flat amount — stays double
  final Money discountAmount;
  final String vatMode;
  final double vatRate; // Rate/percentage — stays double
  final Money vatAmount;
  final String orderType;
  final String orderChannel;
  final String? externalOrderRef;
  final String? tableId;
  final double serviceChargeRate; // Rate/percentage — stays double
  final Money serviceChargeAmount;
  final String? customerId;
  final String? promotionId;
  final Money promotionDiscountAmount;
  final Money totalAmount;
  final String paymentMethod;
  final Money? amountReceived;
  final Money? changeAmount;
  final String? note;
  final String? paymentReference;
  final String? sendingBankCode;
  final DateTime? voidedAt;
  final String? voidReason;
  final DateTime createdAt;
  final List<SaleItem> items;
  final List<SalePayment> payments;

  bool get isVoided => status == 'VOIDED';

  /// Single-tender: first payment method; multi may use header [paymentMethod].
  String get primaryPaymentMethod =>
      payments.length == 1 ? payments.first.method : paymentMethod;

  @override
  List<Object?> get props => [
    id,
    receiptNumber,
    status,
    subtotalAmount,
    discountType,
    discountValue,
    discountAmount,
    vatMode,
    vatRate,
    vatAmount,
    orderType,
    orderChannel,
    externalOrderRef,
    tableId,
    serviceChargeRate,
    serviceChargeAmount,
    customerId,
    promotionId,
    promotionDiscountAmount,
    totalAmount,
    paymentMethod,
    amountReceived,
    changeAmount,
    note,
    paymentReference,
    sendingBankCode,
    voidedAt,
    voidReason,
    createdAt,
    items,
    payments,
  ];
}
