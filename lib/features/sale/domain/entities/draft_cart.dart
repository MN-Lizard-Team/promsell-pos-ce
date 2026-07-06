import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

class DraftCart extends Equatable {
  const DraftCart({
    required this.id,
    required this.items,
    this.name,
    this.note,
    this.cartDiscountType,
    this.cartDiscountValue,
    this.orderType = 'dinein',
    this.orderChannel = 'walkin',
    this.externalOrderRef,
    this.tableId,
    this.serviceChargeRate,
    this.customerId,
    this.promotionId,
    this.promotionDiscountAmount = 0.0,
    required this.updatedAt,
    this.deletedAt,
    this.version = 1,
  });

  final String id;
  final List<CartItem> items;
  final String? name;
  final String? note;
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
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;

  String get displayName => name?.isNotEmpty == true ? name! : 'Draft';

  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  double get _rawTotal =>
      MoneyUtils.round(items.fold(0.0, (sum, i) => sum + i.subtotal));

  double get discountAmount {
    if (cartDiscountType == null ||
        cartDiscountValue == null ||
        cartDiscountValue! <= 0) {
      return 0.0;
    }
    if (cartDiscountType == 'PERCENT') {
      return MoneyUtils.round(_rawTotal * (cartDiscountValue! / 100));
    }
    return MoneyUtils.round(cartDiscountValue!.clamp(0.0, _rawTotal));
  }

  double get total => MoneyUtils.round(_rawTotal - discountAmount);

  double get serviceChargeAmount {
    final rate = serviceChargeRate;
    if (rate == null || rate <= 0) return 0.0;
    return MoneyUtils.round(total * (rate / 100));
  }

  double get grandTotal => MoneyUtils.round(total + serviceChargeAmount);

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
  ];
}
