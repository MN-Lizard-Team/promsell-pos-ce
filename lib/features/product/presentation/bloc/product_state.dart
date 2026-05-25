import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

const Object _unset = Object();

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  final ProductStatus status;
  final List<Product> products;
  final String searchQuery;
  final String? errorMessage;

  List<Product> get filtered {
    if (searchQuery.isEmpty) return products;
    final q = searchQuery.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            (p.category?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? searchQuery,
    Object? errorMessage = _unset,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, products, searchQuery, errorMessage];
}
