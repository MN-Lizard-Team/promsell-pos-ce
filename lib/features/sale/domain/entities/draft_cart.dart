import 'package:equatable/equatable.dart';
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
  });

  final String id;
  final List<CartItem> items;
  final String? name;
  final String? note;
  final String? cartDiscountType;
  final double? cartDiscountValue;
  final DateTime updatedAt;

  String get displayName => name?.isNotEmpty == true ? name! : 'Draft';

  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  double get _rawTotal => double.parse(
    items.fold(0.0, (sum, i) => sum + i.subtotal).toStringAsFixed(2),
  );

  double get discountAmount {
    if (cartDiscountType == null ||
        cartDiscountValue == null ||
        cartDiscountValue! <= 0) {
      return 0.0;
    }
    if (cartDiscountType == 'PERCENT') {
      return double.parse(
        (_rawTotal * (cartDiscountValue! / 100)).toStringAsFixed(2),
      );
    }
    return double.parse(
      cartDiscountValue!.clamp(0.0, _rawTotal).toStringAsFixed(2),
    );
  }

  double get total =>
      double.parse((_rawTotal - discountAmount).toStringAsFixed(2));

  @override
  List<Object?> get props => [
    id,
    items,
    name,
    note,
    cartDiscountType,
    cartDiscountValue,
    updatedAt,
  ];
}
