import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.qty});

  final Product product;
  final int qty;

  double get subtotal => double.parse((product.price * qty).toStringAsFixed(2));

  CartItem copyWith({Product? product, int? qty}) =>
      CartItem(product: product ?? this.product, qty: qty ?? this.qty);

  @override
  List<Object?> get props => [product, qty];
}
