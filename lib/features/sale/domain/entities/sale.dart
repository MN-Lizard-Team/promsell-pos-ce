import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.subtotal,
  });

  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final double price;
  final int qty;
  final double subtotal;

  @override
  List<Object?> get props => [
    id,
    saleId,
    productId,
    productName,
    price,
    qty,
    subtotal,
  ];
}

class Sale extends Equatable {
  const Sale({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    this.receiptNumber,
    this.status = 'COMPLETED',
    this.amountReceived,
    this.changeAmount,
    this.note,
    this.voidedAt,
    this.voidReason,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final String? receiptNumber;
  final String status;
  final double totalAmount;
  final String paymentMethod;
  final double? amountReceived;
  final double? changeAmount;
  final String? note;
  final DateTime? voidedAt;
  final String? voidReason;
  final DateTime createdAt;
  final List<SaleItem> items;

  bool get isVoided => status == 'VOIDED';

  @override
  List<Object?> get props => [
    id,
    receiptNumber,
    status,
    totalAmount,
    paymentMethod,
    amountReceived,
    changeAmount,
    note,
    voidedAt,
    voidReason,
    createdAt,
    items,
  ];
}
