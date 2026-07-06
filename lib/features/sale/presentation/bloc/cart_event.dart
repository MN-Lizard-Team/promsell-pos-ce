import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartProductAdded extends CartEvent {
  const CartProductAdded(
    this.product, {
    this.qty = 1,
    this.allowOversell = false,
    this.selectedOptions = const [],
  });
  final Product product;
  final int qty;
  final bool allowOversell;
  final List<SelectedProductOption> selectedOptions;
  @override
  List<Object?> get props => [product, qty, allowOversell, selectedOptions];
}

class CartProductRemoved extends CartEvent {
  const CartProductRemoved(this.productId, {this.lineId});
  final String productId;
  final String? lineId;
  @override
  List<Object?> get props => [productId, lineId];
}

class CartItemQtyChanged extends CartEvent {
  const CartItemQtyChanged({
    required this.productId,
    required this.qty,
    this.allowOversell = false,
    this.lineId,
  });
  final String productId;
  final int qty;
  final bool allowOversell;
  final String? lineId;
  @override
  List<Object?> get props => [productId, qty, allowOversell, lineId];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartRestored extends CartEvent {
  const CartRestored({
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

class CartItemRestored extends CartEvent {
  const CartItemRestored(this.item);
  final CartItem item;
  @override
  List<Object?> get props => [item];
}

class CartItemDiscountChanged extends CartEvent {
  const CartItemDiscountChanged({
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

class CartItemDiscountCleared extends CartEvent {
  const CartItemDiscountCleared(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

class CartDiscountChanged extends CartEvent {
  const CartDiscountChanged({
    required this.discountType,
    required this.discountValue,
  });
  final String discountType;
  final double discountValue;
  @override
  List<Object?> get props => [discountType, discountValue];
}

class CartDiscountCleared extends CartEvent {
  const CartDiscountCleared();
}

class CartNoteChanged extends CartEvent {
  const CartNoteChanged(this.note);
  final String note;
  @override
  List<Object?> get props => [note];
}

class CartProductsRefreshed extends CartEvent {
  const CartProductsRefreshed(this.products);
  final List<Product> products;
  @override
  List<Object?> get props => [products];
}

class CartBarcodeScanned extends CartEvent {
  const CartBarcodeScanned(this.barcode);
  final String barcode;
  @override
  List<Object?> get props => [barcode];
}

class CartBulkItemsRemoved extends CartEvent {
  const CartBulkItemsRemoved(this.productIds);
  final List<String> productIds;
  @override
  List<Object?> get props => [productIds];
}

class CartBulkItemDiscountsCleared extends CartEvent {
  const CartBulkItemDiscountsCleared(this.productIds);
  final List<String> productIds;
  @override
  List<Object?> get props => [productIds];
}

class CartItemsReordered extends CartEvent {
  const CartItemsReordered(this.productIds);
  final List<String> productIds;
  @override
  List<Object?> get props => [productIds];
}

class CartItemNoteChanged extends CartEvent {
  const CartItemNoteChanged({required this.productId, this.note});
  final String productId;
  final String? note;
  @override
  List<Object?> get props => [productId, note];
}

class CartTableAssigned extends CartEvent {
  const CartTableAssigned(this.tableId);
  final String? tableId;
  @override
  List<Object?> get props => [tableId];
}

class CartOrderTypeChanged extends CartEvent {
  const CartOrderTypeChanged(this.orderType);
  final String orderType;
  @override
  List<Object?> get props => [orderType];
}

class CartOrderChannelChanged extends CartEvent {
  const CartOrderChannelChanged(this.orderChannel);
  final String orderChannel;
  @override
  List<Object?> get props => [orderChannel];
}

class CartExternalOrderRefChanged extends CartEvent {
  const CartExternalOrderRefChanged(this.externalOrderRef);
  final String? externalOrderRef;
  @override
  List<Object?> get props => [externalOrderRef];
}

class CartServiceChargeRateChanged extends CartEvent {
  const CartServiceChargeRateChanged(this.rate);
  final double? rate;
  @override
  List<Object?> get props => [rate];
}
