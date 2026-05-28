import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.qty,
    this.discountType,
    this.discountValue,
  });

  final Product product;
  final int qty;
  final String? discountType;
  final double? discountValue;

  double get rawSubtotal =>
      double.parse((product.price * qty).toStringAsFixed(2));

  double get discountAmount {
    if (discountType == null || discountValue == null || discountValue! <= 0) {
      return 0.0;
    }
    if (discountType == 'PERCENT') {
      return double.parse(
        (rawSubtotal * (discountValue! / 100)).toStringAsFixed(2),
      );
    }
    return double.parse(
      discountValue!.clamp(0.0, rawSubtotal).toStringAsFixed(2),
    );
  }

  double get subtotal =>
      double.parse((rawSubtotal - discountAmount).toStringAsFixed(2));

  CartItem copyWith({
    Product? product,
    int? qty,
    Object? discountType = _unset,
    Object? discountValue = _unset,
  }) => CartItem(
    product: product ?? this.product,
    qty: qty ?? this.qty,
    discountType: identical(discountType, _unset)
        ? this.discountType
        : discountType as String?,
    discountValue: identical(discountValue, _unset)
        ? this.discountValue
        : discountValue as double?,
  );

  CartItem clearDiscount() => CartItem(product: product, qty: qty);

  @override
  List<Object?> get props => [product, qty, discountType, discountValue];
}

const Object _unset = Object();
