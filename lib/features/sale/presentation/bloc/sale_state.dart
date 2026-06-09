import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

const Object _unset = Object();

enum SaleStatus { idle, processing, waitingPayment, success, failure }

class SaleState extends Equatable {
  const SaleState({
    this.status = SaleStatus.idle,
    this.items = const [],
    this.note = '',
    this.lastSale,
    this.errorMessage,
    this.cartDiscountType,
    this.cartDiscountValue,
    this.activeDraftId,
    this.activeDraftName,
  });

  final SaleStatus status;
  final List<CartItem> items;
  final String note;
  final Sale? lastSale;
  final String? errorMessage;
  final String? cartDiscountType;
  final double? cartDiscountValue;
  final String? activeDraftId;
  final String? activeDraftName;

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

  SaleState copyWith({
    SaleStatus? status,
    List<CartItem>? items,
    String? note,
    Object? lastSale = _unset,
    Object? errorMessage = _unset,
    Object? cartDiscountType = _unset,
    Object? cartDiscountValue = _unset,
    Object? activeDraftId = _unset,
    Object? activeDraftName = _unset,
  }) => SaleState(
    status: status ?? this.status,
    items: items ?? this.items,
    note: note ?? this.note,
    lastSale: identical(lastSale, _unset) ? this.lastSale : lastSale as Sale?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    cartDiscountType: identical(cartDiscountType, _unset)
        ? this.cartDiscountType
        : cartDiscountType as String?,
    cartDiscountValue: identical(cartDiscountValue, _unset)
        ? this.cartDiscountValue
        : cartDiscountValue as double?,
    activeDraftId: identical(activeDraftId, _unset)
        ? this.activeDraftId
        : activeDraftId as String?,
    activeDraftName: identical(activeDraftName, _unset)
        ? this.activeDraftName
        : activeDraftName as String?,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    note,
    lastSale,
    errorMessage,
    cartDiscountType,
    cartDiscountValue,
    activeDraftId,
    activeDraftName,
  ];
}
