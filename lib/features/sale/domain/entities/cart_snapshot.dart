import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

class CartSnapshot {
  const CartSnapshot({
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
}
