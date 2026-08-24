import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/shared/domain/entities/selected_product_option.dart';

/// A single line item on a completed sale.
///
/// Shared domain entity — used by sale, report, history, receipt, and home
/// features. Lives in `lib/shared/domain/` to avoid cross-feature domain
/// coupling.
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

/// A completed (or voided) sale transaction.
///
/// Shared domain entity — used by sale, report, history, receipt, daily close,
/// and home features. Lives in `lib/shared/domain/` to avoid cross-feature
/// domain coupling.
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

  Sale copyWith({
    String? id,
    String? receiptNumber,
    String? status,
    Money? subtotalAmount,
    String? discountType,
    double? discountValue,
    Money? discountAmount,
    String? vatMode,
    double? vatRate,
    Money? vatAmount,
    String? orderType,
    String? orderChannel,
    String? externalOrderRef,
    String? tableId,
    double? serviceChargeRate,
    Money? serviceChargeAmount,
    String? customerId,
    String? promotionId,
    Money? promotionDiscountAmount,
    Money? totalAmount,
    String? paymentMethod,
    Money? amountReceived,
    Money? changeAmount,
    String? note,
    String? paymentReference,
    String? sendingBankCode,
    DateTime? voidedAt,
    String? voidReason,
    DateTime? createdAt,
    List<SaleItem>? items,
    List<SalePayment>? payments,
  }) {
    return Sale(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      status: status ?? this.status,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      vatMode: vatMode ?? this.vatMode,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
      orderType: orderType ?? this.orderType,
      orderChannel: orderChannel ?? this.orderChannel,
      externalOrderRef: externalOrderRef ?? this.externalOrderRef,
      tableId: tableId ?? this.tableId,
      serviceChargeRate: serviceChargeRate ?? this.serviceChargeRate,
      serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
      customerId: customerId ?? this.customerId,
      promotionId: promotionId ?? this.promotionId,
      promotionDiscountAmount:
          promotionDiscountAmount ?? this.promotionDiscountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountReceived: amountReceived ?? this.amountReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      note: note ?? this.note,
      paymentReference: paymentReference ?? this.paymentReference,
      sendingBankCode: sendingBankCode ?? this.sendingBankCode,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      payments: payments ?? this.payments,
    );
  }

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
