import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

const Object _unset = Object();

class CartState extends Equatable {
  const CartState({
    this.items = const [],
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
    this.stockWarning,
    this.errorMessage,
    this.lastFailedBarcode,
    this.errorNonce = 0,
    this.paymentLocked = false,
    Money? cachedItemsSubtotal,
    Money? cachedCartDiscountAmount,
    Money? cachedTotal,
    Money? cachedServiceChargeAmount,
  }) : _cachedItemsSubtotal = cachedItemsSubtotal,
       _cachedCartDiscountAmount = cachedCartDiscountAmount,
       _cachedTotal = cachedTotal,
       _cachedServiceChargeAmount = cachedServiceChargeAmount;

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
  final String? stockWarning;
  final String? errorMessage;

  /// Barcode that failed lookup (for not-found create CTA). Cleared on success.
  final String? lastFailedBarcode;
  final int errorNonce;

  /// When true, CartBloc rejects mutations except clear/unlock.
  final bool paymentLocked;

  final Money? _cachedItemsSubtotal;
  final Money? _cachedCartDiscountAmount;
  final Money? _cachedTotal;
  final Money? _cachedServiceChargeAmount;

  Money get itemsSubtotal {
    if (_cachedItemsSubtotal != null) return _cachedItemsSubtotal;
    return _computeItemsSubtotal();
  }

  Money get cartDiscountAmount {
    if (_cachedCartDiscountAmount != null) return _cachedCartDiscountAmount;
    return _computeCartDiscountAmount();
  }

  Money get total {
    if (_cachedTotal != null) return _cachedTotal;
    return _computeTotal();
  }

  Money get serviceChargeAmount {
    if (_cachedServiceChargeAmount != null) return _cachedServiceChargeAmount;
    return _computeServiceChargeAmount();
  }

  Money _computeItemsSubtotal() =>
      items.fold(Money.zero, (sum, i) => sum + i.subtotal);

  Money _computeCartDiscountAmount() {
    if (cartDiscountType == null ||
        cartDiscountValue == null ||
        cartDiscountValue! <= 0) {
      return Money.zero;
    }
    final subtotal = itemsSubtotal;
    if (cartDiscountType == 'PERCENT') {
      return subtotal * (cartDiscountValue! / 100);
    }
    final maxDiscount = subtotal.value;
    final discountValue = cartDiscountValue!.clamp(0.0, maxDiscount);
    return Money.fromDouble(discountValue);
  }

  Money get promotionDiscountMoney =>
      Money.fromDouble(promotionDiscountAmount).clampToZero();

  /// Items after cart + promotion discounts (before service charge / VAT).
  Money _computeTotal() =>
      (itemsSubtotal - cartDiscountAmount - promotionDiscountMoney)
          .clampToZero();

  Money _computeServiceChargeAmount() {
    final rate = serviceChargeRate;
    if (rate == null || rate <= 0) return Money.zero;
    return total * (rate / 100);
  }

  /// Payable SSOT (SC default + VAT) for display and checkout alignment.
  SalePayableTotals payableTotals(Settings settings) =>
      SalePayableCalculator.forCartFields(
        itemsSubtotal: itemsSubtotal,
        cartDiscountAmount: cartDiscountAmount,
        promotionDiscountAmount: promotionDiscountMoney,
        settings: settings,
        cartServiceChargeRate: serviceChargeRate,
      );

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);
  bool get hasCartDiscount =>
      cartDiscountType != null && (cartDiscountValue ?? 0) > 0;

  CartState copyWith({
    List<CartItem>? items,
    String? note,
    Object? cartDiscountType = _unset,
    Object? cartDiscountValue = _unset,
    String? orderType,
    String? orderChannel,
    Object? externalOrderRef = _unset,
    Object? tableId = _unset,
    Object? serviceChargeRate = _unset,
    Object? customerId = _unset,
    Object? promotionId = _unset,
    double? promotionDiscountAmount,
    Object? stockWarning = _unset,
    Object? errorMessage = _unset,
    Object? lastFailedBarcode = _unset,
    int? errorNonce,
    bool? paymentLocked,
  }) {
    final newState = CartState(
      items: items ?? this.items,
      note: note ?? this.note,
      cartDiscountType: identical(cartDiscountType, _unset)
          ? this.cartDiscountType
          : cartDiscountType as String?,
      cartDiscountValue: identical(cartDiscountValue, _unset)
          ? this.cartDiscountValue
          : cartDiscountValue as double?,
      orderType: orderType ?? this.orderType,
      orderChannel: orderChannel ?? this.orderChannel,
      externalOrderRef: identical(externalOrderRef, _unset)
          ? this.externalOrderRef
          : externalOrderRef as String?,
      tableId: identical(tableId, _unset) ? this.tableId : tableId as String?,
      serviceChargeRate: identical(serviceChargeRate, _unset)
          ? this.serviceChargeRate
          : serviceChargeRate as double?,
      customerId: identical(customerId, _unset)
          ? this.customerId
          : customerId as String?,
      promotionId: identical(promotionId, _unset)
          ? this.promotionId
          : promotionId as String?,
      promotionDiscountAmount:
          promotionDiscountAmount ?? this.promotionDiscountAmount,
      stockWarning: identical(stockWarning, _unset)
          ? this.stockWarning
          : stockWarning as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      lastFailedBarcode: identical(lastFailedBarcode, _unset)
          ? this.lastFailedBarcode
          : lastFailedBarcode as String?,
      errorNonce: errorNonce ?? this.errorNonce,
      paymentLocked: paymentLocked ?? this.paymentLocked,
    );

    return CartState(
      items: newState.items,
      note: newState.note,
      cartDiscountType: newState.cartDiscountType,
      cartDiscountValue: newState.cartDiscountValue,
      orderType: newState.orderType,
      orderChannel: newState.orderChannel,
      externalOrderRef: newState.externalOrderRef,
      tableId: newState.tableId,
      serviceChargeRate: newState.serviceChargeRate,
      customerId: newState.customerId,
      promotionId: newState.promotionId,
      promotionDiscountAmount: newState.promotionDiscountAmount,
      stockWarning: newState.stockWarning,
      errorMessage: newState.errorMessage,
      lastFailedBarcode: newState.lastFailedBarcode,
      errorNonce: newState.errorNonce,
      paymentLocked: newState.paymentLocked,
      cachedItemsSubtotal: newState._computeItemsSubtotal(),
      cachedCartDiscountAmount: newState._computeCartDiscountAmount(),
      cachedTotal: newState._computeTotal(),
      cachedServiceChargeAmount: newState._computeServiceChargeAmount(),
    );
  }

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
    stockWarning,
    errorMessage,
    lastFailedBarcode,
    errorNonce,
    paymentLocked,
  ];
}
