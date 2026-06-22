import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

const Object _unset = Object();

enum ProductStatus { initial, loading, success, failure }

enum ProductSaveStatus { idle, saving, saved, error }

const String kNoCategoryFilter = '__none__';

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.searchQuery = '',
    this.categoryFilter,
    this.errorMessage,
    this.saveStatus = ProductSaveStatus.idle,
    this.batchResultMessage,
  });

  final ProductStatus status;
  final List<Product> products;
  final String searchQuery;
  final String? categoryFilter;
  final String? errorMessage;
  final ProductSaveStatus saveStatus;
  final String? batchResultMessage;

  List<Product> get filtered {
    var result = products;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.sku?.toLowerCase().contains(q) ?? false) ||
                (p.barcode?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    if (categoryFilter != null) {
      if (categoryFilter == kNoCategoryFilter) {
        result = result.where((p) => p.categoryId == null).toList();
      } else {
        result = result.where((p) => p.categoryId == categoryFilter).toList();
      }
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
    Object? batchResultMessage = _unset,
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
      batchResultMessage: identical(batchResultMessage, _unset)
          ? this.batchResultMessage
          : batchResultMessage as String?,
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
    batchResultMessage,
  ];
}
