import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();
  @override
  List<Object?> get props => [];
}

class SaleProductAdded extends SaleEvent {
  const SaleProductAdded(this.product, {this.allowOversell = false});
  final Product product;
  final bool allowOversell;
  @override
  List<Object?> get props => [product, allowOversell];
}

class SaleProductRemoved extends SaleEvent {
  const SaleProductRemoved(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

class SaleItemQtyChanged extends SaleEvent {
  const SaleItemQtyChanged({
    required this.productId,
    required this.qty,
    this.allowOversell = false,
  });
  final String productId;
  final int qty;
  final bool allowOversell;
  @override
  List<Object?> get props => [productId, qty, allowOversell];
}

class SaleCartCleared extends SaleEvent {
  const SaleCartCleared();
}

class SaleCartRestored extends SaleEvent {
  const SaleCartRestored({
    required this.items,
    this.cartDiscountType,
    this.cartDiscountValue,
  });
  final List<CartItem> items;
  final String? cartDiscountType;
  final double? cartDiscountValue;
  @override
  List<Object?> get props => [items, cartDiscountType, cartDiscountValue];
}

class SaleCartItemRestored extends SaleEvent {
  const SaleCartItemRestored(this.item);
  final CartItem item;
  @override
  List<Object?> get props => [item];
}

class SaleConfirmed extends SaleEvent {
  const SaleConfirmed({
    required this.paymentMethod,
    required this.vatMode,
    required this.vatRate,
    this.cartDiscountType,
    this.cartDiscountValue,
    this.cartDiscountAmount,
    this.amountReceived,
    this.changeAmount,
    this.note,
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
  ];
}

class SaleItemDiscountChanged extends SaleEvent {
  const SaleItemDiscountChanged({
    required this.productId,
    required this.discountType,
    required this.discountValue,
  });
  final String productId;
  final String discountType;
  final double discountValue;
  @override
  List<Object?> get props => [productId, discountType, discountValue];
}

class SaleItemDiscountCleared extends SaleEvent {
  const SaleItemDiscountCleared(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

class SaleCartDiscountChanged extends SaleEvent {
  const SaleCartDiscountChanged({
    required this.discountType,
    required this.discountValue,
  });
  final String discountType;
  final double discountValue;
  @override
  List<Object?> get props => [discountType, discountValue];
}

class SaleCartDiscountCleared extends SaleEvent {
  const SaleCartDiscountCleared();
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

class SaleReset extends SaleEvent {
  const SaleReset();
}

class SaleDraftInitialized extends SaleEvent {
  const SaleDraftInitialized();
}

class SaleDraftSwitched extends SaleEvent {
  const SaleDraftSwitched(this.draftId);
  final String draftId;
  @override
  List<Object?> get props => [draftId];
}

class SaleDraftCreated extends SaleEvent {
  const SaleDraftCreated({this.name});
  final String? name;
  @override
  List<Object?> get props => [name];
}

class SaleDraftDeleted extends SaleEvent {
  const SaleDraftDeleted(this.draftId);
  final String draftId;
  @override
  List<Object?> get props => [draftId];
}

class SaleDraftRenamed extends SaleEvent {
  const SaleDraftRenamed({required this.draftId, required this.name});
  final String draftId;
  final String name;
  @override
  List<Object?> get props => [draftId, name];
}

class SaleBulkItemsRemoved extends SaleEvent {
  const SaleBulkItemsRemoved(this.productIds);
  final List<String> productIds;
  @override
  List<Object?> get props => [productIds];
}

class SaleBulkItemDiscountsCleared extends SaleEvent {
  const SaleBulkItemDiscountsCleared(this.productIds);
  final List<String> productIds;
  @override
  List<Object?> get props => [productIds];
}

class SaleCartItemsReordered extends SaleEvent {
  const SaleCartItemsReordered(this.productIds);
  final List<String> productIds;
  @override
  List<Object?> get props => [productIds];
}
