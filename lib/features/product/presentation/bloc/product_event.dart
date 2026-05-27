import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductsSubscribed extends ProductEvent {
  const ProductsSubscribed();
}

class ProductAdded extends ProductEvent {
  const ProductAdded({
    required this.name,
    required this.price,
    required this.stock,
    this.category,
    this.imageUrl,
  });
  final String name;
  final double price;
  final int stock;
  final String? category;
  final String? imageUrl;

  @override
  List<Object?> get props => [name, price, stock, category, imageUrl];
}

class ProductUpdated extends ProductEvent {
  const ProductUpdated(this.product);
  final Product product;

  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductEvent {
  const ProductDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ProductSearchChanged extends ProductEvent {
  const ProductSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}
