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

  final int id;
  final int saleId;
  final int productId;
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
    this.amountReceived,
    this.changeAmount,
    this.note,
    required this.createdAt,
    this.items = const [],
  });

  final int id;
  final double totalAmount;
  final String paymentMethod;
  final double? amountReceived;
  final double? changeAmount;
  final String? note;
  final DateTime createdAt;
  final List<SaleItem> items;

  @override
  List<Object?> get props => [
    id,
    totalAmount,
    paymentMethod,
    amountReceived,
    changeAmount,
    note,
    createdAt,
    items,
  ];
}
