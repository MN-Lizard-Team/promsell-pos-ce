import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

const Object _unset = Object();

class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.note = '',
    this.cartDiscountType,
    this.cartDiscountValue,
    this.stockWarning,
    this.errorMessage,
    this.errorNonce = 0,
  });

  final List<CartItem> items;
  final String note;
  final String? cartDiscountType;
  final double? cartDiscountValue;
  final String? stockWarning;
  final String? errorMessage;
  final int errorNonce;

  double get itemsSubtotal =>
      MoneyUtils.round(items.fold(0.0, (sum, i) => sum + i.subtotal));

  double get cartDiscountAmount {
    if (cartDiscountType == null ||
        cartDiscountValue == null ||
        cartDiscountValue! <= 0) {
      return 0.0;
    }
    if (cartDiscountType == 'PERCENT') {
      return MoneyUtils.round(itemsSubtotal * (cartDiscountValue! / 100));
    }
    return MoneyUtils.round(cartDiscountValue!.clamp(0.0, itemsSubtotal));
  }

  double get total => MoneyUtils.round(itemsSubtotal - cartDiscountAmount);

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);
  bool get hasCartDiscount =>
      cartDiscountType != null && (cartDiscountValue ?? 0) > 0;

  CartState copyWith({
    List<CartItem>? items,
    String? note,
    Object? cartDiscountType = _unset,
    Object? cartDiscountValue = _unset,
    Object? stockWarning = _unset,
    Object? errorMessage = _unset,
    int? errorNonce,
  }) => CartState(
    items: items ?? this.items,
    note: note ?? this.note,
    cartDiscountType: identical(cartDiscountType, _unset)
        ? this.cartDiscountType
        : cartDiscountType as String?,
    cartDiscountValue: identical(cartDiscountValue, _unset)
        ? this.cartDiscountValue
        : cartDiscountValue as double?,
    stockWarning: identical(stockWarning, _unset)
        ? this.stockWarning
        : stockWarning as String?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    errorNonce: errorNonce ?? this.errorNonce,
  );

  @override
  List<Object?> get props => [
    items,
    note,
    cartDiscountType,
    cartDiscountValue,
    stockWarning,
    errorMessage,
    errorNonce,
  ];
}
