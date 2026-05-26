import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();
  @override
  List<Object?> get props => [];
}

class SaleProductAdded extends SaleEvent {
  const SaleProductAdded(this.product);
  final Product product;
  @override
  List<Object?> get props => [product];
}

class SaleProductRemoved extends SaleEvent {
  const SaleProductRemoved(this.productId);
  final int productId;
  @override
  List<Object?> get props => [productId];
}

class SaleItemQtyChanged extends SaleEvent {
  const SaleItemQtyChanged({required this.productId, required this.qty});
  final int productId;
  final int qty;
  @override
  List<Object?> get props => [productId, qty];
}

class SaleCartCleared extends SaleEvent {
  const SaleCartCleared();
}

class SaleConfirmed extends SaleEvent {
  const SaleConfirmed({
    required this.paymentMethod,
    this.amountReceived,
    this.changeAmount,
    this.note,
  });
  final String paymentMethod;
  final double? amountReceived;
  final double? changeAmount;
  final String? note;
  @override
  List<Object?> get props => [
    paymentMethod,
    amountReceived,
    changeAmount,
    note,
  ];
}

class SaleNoteChanged extends SaleEvent {
  const SaleNoteChanged(this.note);
  final String note;
  @override
  List<Object?> get props => [note];
}

class SaleCartProductsRefreshed extends SaleEvent {
  const SaleCartProductsRefreshed(this.products);
  final List<Product> products;
  @override
  List<Object?> get props => [products];
}
