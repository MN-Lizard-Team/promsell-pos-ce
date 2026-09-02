import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

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

/// Clears the cart. User clear is blocked while [CartState.paymentLocked].
///
/// Pass [force] true for system paths only (post-sale, park success, checkout
/// reset) so mid-payment clear cannot drop the lock and desync freeze vs live cart.
class CartCleared extends CartEvent {
  const CartCleared({this.force = false});

  /// When true, bypass payment lock (post-sale / park / system reset only).
  final bool force;

  @override
  List<Object?> get props => [force];
}

/// Full cart session restore (draft load, clear-undo). Prefer factories so
/// meta fields are not dropped when only items/discount are set.
class CartRestored extends CartEvent {
  const CartRestored({
    required this.items,
    this.note = '',
    this.cartDiscountType,
    this.cartDiscountValue,
    this.orderType = 'delivery',
    this.orderChannel = 'walkin',
    this.externalOrderRef,
    this.tableId,
    this.serviceChargeRate,
    this.customerId,
    this.promotionId,
    this.promotionDiscountAmount = 0.0,
    this.guestCount,
    this.openedAt,
  });

  factory CartRestored.fromCartState(CartState state) => CartRestored(
    items: List<CartItem>.from(state.items),
    note: state.note,
    cartDiscountType: state.cartDiscountType,
    cartDiscountValue: state.cartDiscountValue,
    orderType: state.orderType,
    orderChannel: state.orderChannel,
    externalOrderRef: state.externalOrderRef,
    tableId: state.tableId,
    serviceChargeRate: state.serviceChargeRate,
    customerId: state.customerId,
    promotionId: state.promotionId,
    promotionDiscountAmount: state.promotionDiscountAmount,
    guestCount: state.guestCount,
    openedAt: state.openedAt,
  );

  final List<CartItem> items;
  final String note;
  final String? cartDiscountType;
  final double? cartDiscountValue;
  final String orderType;
  final String orderChannel;
  final String? externalOrderRef;
  final String? tableId;
  final double? serviceChargeRate;
  final String? customerId;
  final String? promotionId;
  final double promotionDiscountAmount;
  final int? guestCount;
  final DateTime? openedAt;

  @override
  List<Object?> get props => [
    items,
    note,
    cartDiscountType,
    cartDiscountValue,
    orderType,
    orderChannel,
    externalOrderRef,
    tableId,
    serviceChargeRate,
    customerId,
    promotionId,
    promotionDiscountAmount,
    guestCount,
    openedAt,
  ];
}

class CartItemRestored extends CartEvent {
  const CartItemRestored(this.item);
  final CartItem item;
  @override
  List<Object?> get props => [item];
}

class CartItemDuplicated extends CartEvent {
  const CartItemDuplicated(this.item);
  final CartItem item;
  @override
  List<Object?> get props => [item];
}

class CartItemDiscountChanged extends CartEvent {
  const CartItemDiscountChanged({
    required this.productId,
    required this.discountType,
    required this.discountValue,
    this.lineId,
  });
  final String productId;
  final String discountType;
  final double discountValue;
  final String? lineId;
  @override
  List<Object?> get props => [productId, discountType, discountValue, lineId];
}

class CartItemDiscountCleared extends CartEvent {
  const CartItemDiscountCleared(this.productId, {this.lineId});
  final String productId;
  final String? lineId;
  @override
  List<Object?> get props => [productId, lineId];
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

/// Bulk remove by **lineId** (not productId — optioned lines share productId).
class CartBulkItemsRemoved extends CartEvent {
  const CartBulkItemsRemoved(this.lineIds);
  final List<String> lineIds;
  @override
  List<Object?> get props => [lineIds];
}

/// Clear line discounts by **lineId**.
class CartBulkItemDiscountsCleared extends CartEvent {
  const CartBulkItemDiscountsCleared(this.lineIds);
  final List<String> lineIds;
  @override
  List<Object?> get props => [lineIds];
}

/// Reorder cart lines by **lineId** sequence.
class CartItemsReordered extends CartEvent {
  const CartItemsReordered(this.lineIds);
  final List<String> lineIds;
  @override
  List<Object?> get props => [lineIds];
}

class CartItemNoteChanged extends CartEvent {
  const CartItemNoteChanged({required this.productId, this.note, this.lineId});
  final String productId;
  final String? note;
  final String? lineId;
  @override
  List<Object?> get props => [productId, note, lineId];
}

class CartTableAssigned extends CartEvent {
  const CartTableAssigned(this.tableId);
  final String? tableId;
  @override
  List<Object?> get props => [tableId];
}

/// Set or clear the number of guests on the cart (draft-autosaved).
class CartGuestCountChanged extends CartEvent {
  const CartGuestCountChanged(this.guestCount);
  final int? guestCount;
  @override
  List<Object?> get props => [guestCount];
}

/// Attach or clear loyalty customer on the cart (draft-autosaved).
class CartCustomerSet extends CartEvent {
  const CartCustomerSet(this.customerId);
  final String? customerId;
  @override
  List<Object?> get props => [customerId];
}

/// Attach or clear a promotion; amount is resolved via [Promotion.discountFor].
class CartPromotionSet extends CartEvent {
  const CartPromotionSet(this.promotionId);
  final String? promotionId;
  @override
  List<Object?> get props => [promotionId];
}

/// Internal: recompute promotion discount after cart totals change.
class CartPromotionRecompute extends CartEvent {
  const CartPromotionRecompute();
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

/// Hard-lock cart mutations while checkout is waitingPayment/processing.
class CartPaymentLockChanged extends CartEvent {
  const CartPaymentLockChanged(this.locked);
  final bool locked;
  @override
  List<Object?> get props => [locked];
}
