import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class DraftCart extends Equatable {
  const DraftCart({
    required this.id,
    required this.items,
    this.name,
    this.note,
    this.cartDiscountType,
    this.cartDiscountValue,
    this.orderType = 'delivery',
    this.orderChannel = 'walkin',
    this.externalOrderRef,
    this.tableId,
    this.serviceChargeRate,
    this.customerId,
    this.promotionId,
    this.promotionDiscountAmount = Money.zero,
    required this.updatedAt,
    this.deletedAt,
    this.version = 1,
    this.skippedItemCount = 0,
    Money? cachedRawTotal,
    Money? cachedCartDiscountAmount,
    Money? cachedTotal,
    Money? cachedServiceChargeAmount,
    Money? cachedGrandTotal,
  }) : _cachedRawTotal = cachedRawTotal,
       _cachedCartDiscountAmount = cachedCartDiscountAmount,
       _cachedTotal = cachedTotal,
       _cachedServiceChargeAmount = cachedServiceChargeAmount,
       _cachedGrandTotal = cachedGrandTotal;

  final String id;
  final List<CartItem> items;
  final String? name;
  final String? note;
  final String? cartDiscountType;
  final double? cartDiscountValue; // Raw value — can be % or flat amount
  final String orderType;
  final String orderChannel;
  final String? externalOrderRef;
  final String? tableId;
  final double? serviceChargeRate; // Rate/percentage — stays double
  final String? customerId;
  final String? promotionId;
  final Money promotionDiscountAmount;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;

  /// Lines dropped on load because the product no longer exists.
  final int skippedItemCount;

  final Money? _cachedRawTotal;
  final Money? _cachedCartDiscountAmount;
  final Money? _cachedTotal;
  final Money? _cachedServiceChargeAmount;
  final Money? _cachedGrandTotal;

  String get displayName => name?.isNotEmpty == true ? name! : '';

  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  Money get _rawTotal {
    return _cachedRawTotal ?? _computeRawTotal();
  }

  Money get cartDiscountAmount {
    return _cachedCartDiscountAmount ?? _computeCartDiscountAmount();
  }

  Money get total {
    return _cachedTotal ?? _computeTotal();
  }

  Money get serviceChargeAmount {
    return _cachedServiceChargeAmount ?? _computeServiceChargeAmount();
  }

  /// Legacy field: items − cart disc only (no promo). Prefer [payableTotal].
  Money get grandTotal {
    return _cachedGrandTotal ?? _computeGrandTotalLegacy();
  }

  /// Customer charge using [SalePayableCalculator] (promo + SC + VAT).
  ///
  /// Pass [settings] when available so SC default / VAT match live cart.
  Money payableTotal([Settings settings = const Settings()]) {
    return SalePayableCalculator.forCartFields(
      itemsSubtotal: _rawTotal,
      cartDiscountAmount: cartDiscountAmount,
      promotionDiscountAmount: promotionDiscountAmount,
      settings: settings,
      cartServiceChargeRate: serviceChargeRate,
    ).payableTotal;
  }

  Money _computeRawTotal() =>
      items.fold(Money.zero, (sum, i) => sum + i.subtotal);

  Money _computeCartDiscountAmount() {
    if (cartDiscountType == null ||
        cartDiscountValue == null ||
        cartDiscountValue! <= 0) {
      return Money.zero;
    }
    final rawTotal = _rawTotal;
    if (cartDiscountType == 'PERCENT') {
      return rawTotal * (cartDiscountValue! / 100);
    }
    // Flat amount — clamp to _rawTotal
    final disc = Money.fromDouble(cartDiscountValue!);
    return disc <= rawTotal ? disc : rawTotal;
  }

  /// Items after cart discount, **before** promo (legacy draft field).
  Money _computeTotal() {
    final afterCart = _rawTotal - cartDiscountAmount;
    return afterCart.clampToZero();
  }

  Money _computeServiceChargeAmount() {
    final rate = serviceChargeRate;
    if (rate == null || rate <= 0) return Money.zero;
    // Apply SC on net after cart disc + promo (align live cart net).
    final net = (_rawTotal - cartDiscountAmount - promotionDiscountAmount)
        .clampToZero();
    return net * (rate / 100);
  }

  Money _computeGrandTotalLegacy() {
    final net = (_rawTotal - cartDiscountAmount - promotionDiscountAmount)
        .clampToZero();
    return net + serviceChargeAmount;
  }

  factory DraftCart.withCache({
    required String id,
    required List<CartItem> items,
    String? name,
    String? note,
    String? cartDiscountType,
    double? cartDiscountValue,
    String orderType = 'delivery',
    String orderChannel = 'walkin',
    String? externalOrderRef,
    String? tableId,
    double? serviceChargeRate,
    String? customerId,
    String? promotionId,
    Money promotionDiscountAmount = Money.zero,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int version = 1,
    int skippedItemCount = 0,
  }) {
    final temp = DraftCart(
      id: id,
      items: items,
      name: name,
      note: note,
      cartDiscountType: cartDiscountType,
      cartDiscountValue: cartDiscountValue,
      orderType: orderType,
      orderChannel: orderChannel,
      externalOrderRef: externalOrderRef,
      tableId: tableId,
      serviceChargeRate: serviceChargeRate,
      customerId: customerId,
      promotionId: promotionId,
      promotionDiscountAmount: promotionDiscountAmount,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      skippedItemCount: skippedItemCount,
    );

    return DraftCart(
      id: id,
      items: items,
      name: name,
      note: note,
      cartDiscountType: cartDiscountType,
      cartDiscountValue: cartDiscountValue,
      orderType: orderType,
      orderChannel: orderChannel,
      externalOrderRef: externalOrderRef,
      tableId: tableId,
      serviceChargeRate: serviceChargeRate,
      customerId: customerId,
      promotionId: promotionId,
      promotionDiscountAmount: promotionDiscountAmount,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      skippedItemCount: skippedItemCount,
      cachedRawTotal: temp._computeRawTotal(),
      cachedCartDiscountAmount: temp._computeCartDiscountAmount(),
      cachedTotal: temp._computeTotal(),
      cachedServiceChargeAmount: temp._computeServiceChargeAmount(),
      cachedGrandTotal: temp._computeGrandTotalLegacy(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    items,
    name,
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
    updatedAt,
    deletedAt,
    version,
    skippedItemCount,
  ];
}
