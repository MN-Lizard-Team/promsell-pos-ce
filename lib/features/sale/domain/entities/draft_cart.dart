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

  @override
  List<Object?> get props => [
    id,
    items,
    name,
    note,
    cartDiscountType,
    cartDiscountValue,
    updatedAt,
    deletedAt,
    version,
  ];
}
