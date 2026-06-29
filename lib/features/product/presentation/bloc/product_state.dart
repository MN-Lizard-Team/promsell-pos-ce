import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

const Object _unset = Object();

enum ProductStatus { initial, loading, success, failure }

enum ProductSaveStatus { idle, saving, saved, error }

const String kNoCategoryFilter = '__none__';

enum StockFilter { all, lowStock, outOfStock }

enum ProductSort { default_, nameAsc, priceLowHigh, priceHighLow, stockLowHigh }

class PriceRange extends Equatable {
  const PriceRange({this.min, this.max});

  final double? min;
  final double? max;

  bool get isActive => min != null || max != null;

  PriceRange copyWith({double? min, double? max}) {
    return PriceRange(min: min ?? this.min, max: max ?? this.max);
  }

  @override
  List<Object?> get props => [min, max];
}

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.searchQuery = '',
    this.categoryFilter,
    this.stockFilter = StockFilter.all,
    this.productSort = ProductSort.default_,
    this.priceRange,
    this.errorMessage,
    this.saveStatus = ProductSaveStatus.idle,
    this.batchResultMessage,
  });

  final ProductStatus status;
  final List<Product> products;
  final String searchQuery;
  final String? categoryFilter;
  final StockFilter stockFilter;
  final ProductSort productSort;
  final PriceRange? priceRange;
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
    if (stockFilter == StockFilter.lowStock) {
      result = result
          .where((p) => p.trackStock && p.stock > 0 && p.stock <= 5)
          .toList();
    } else if (stockFilter == StockFilter.outOfStock) {
      result = result.where((p) => p.trackStock && p.stock == 0).toList();
    }
    switch (productSort) {
      case ProductSort.nameAsc:
        result = result..sort((a, b) => a.name.compareTo(b.name));
      case ProductSort.priceLowHigh:
        result = result..sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighLow:
        result = result..sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.stockLowHigh:
        result = result..sort((a, b) => a.stock.compareTo(b.stock));
      case ProductSort.default_:
        break;
    }
    if (priceRange != null) {
      if (priceRange!.min != null) {
        result = result.where((p) => p.price >= priceRange!.min!).toList();
      }
      if (priceRange!.max != null) {
        result = result.where((p) => p.price <= priceRange!.max!).toList();
      }
    }
    return result;
  }

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? searchQuery,
    Object? categoryFilter = _unset,
    StockFilter? stockFilter,
    ProductSort? productSort,
    Object? priceRange = _unset,
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
      stockFilter: stockFilter ?? this.stockFilter,
      productSort: productSort ?? this.productSort,
      priceRange: identical(priceRange, _unset)
          ? this.priceRange
          : priceRange as PriceRange?,
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
    stockFilter,
    productSort,
    priceRange,
    errorMessage,
    saveStatus,
    batchResultMessage,
  ];
}
