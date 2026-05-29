import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

const Object _unset = Object();

enum ProductStatus { initial, loading, success, failure }

enum ProductSaveStatus { idle, saving, saved, error }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.searchQuery = '',
    this.categoryFilter,
    this.errorMessage,
    this.saveStatus = ProductSaveStatus.idle,
  });

  final ProductStatus status;
  final List<Product> products;
  final String searchQuery;
  final String? categoryFilter;
  final String? errorMessage;
  final ProductSaveStatus saveStatus;

  List<Product> get filtered {
    var result = products;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.category?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    if (categoryFilter != null) {
      result = result.where((p) => p.category == categoryFilter).toList();
    }
    return result;
  }

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? searchQuery,
    Object? categoryFilter = _unset,
    Object? errorMessage = _unset,
    ProductSaveStatus? saveStatus,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: identical(categoryFilter, _unset)
          ? this.categoryFilter
          : categoryFilter as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    searchQuery,
    categoryFilter,
    errorMessage,
    saveStatus,
  ];
}
