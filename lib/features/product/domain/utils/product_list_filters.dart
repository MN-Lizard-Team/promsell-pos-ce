import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_search.dart';

/// Sentinel category id: products with no category.
const String kNoCategoryFilter = '__none__';

enum StockFilter { all, lowStock, outOfStock }

enum ProductSort { default_, nameAsc, priceLowHigh, priceHighLow, stockLowHigh }

/// Inclusive catalog price bounds in [Money] (satang-exact).
class PriceRange extends Equatable {
  const PriceRange({this.min, this.max});

  final Money? min;
  final Money? max;

  bool get isActive => min != null || max != null;

  /// Ensures min ≤ max when both set (for apply / display).
  PriceRange normalized() {
    final a = min;
    final b = max;
    if (a != null && b != null && a > b) {
      return PriceRange(min: b, max: a);
    }
    return this;
  }

  PriceRange copyWith({
    Money? min,
    Money? max,
    bool clearMin = false,
    bool clearMax = false,
  }) {
    return PriceRange(
      min: clearMin ? null : (min ?? this.min),
      max: clearMax ? null : (max ?? this.max),
    );
  }

  /// Display label without currency symbol (e.g. `20 - 80`).
  String displayLabel() {
    final lo = min?.value.toStringAsFixed(0) ?? '';
    final hi = max?.value.toStringAsFixed(0) ?? '';
    return '$lo - $hi'.trim();
  }

  @override
  List<Object?> get props => [min, max];
}

/// Immutable filter/sort/search inputs for [applyProductListFilters].
class ProductListFilterSpec extends Equatable {
  const ProductListFilterSpec({
    this.categoryFilter,
    this.stockFilter = StockFilter.all,
    this.productSort = ProductSort.default_,
    this.priceRange,
    this.searchQuery = '',
    this.lowStockThreshold = 5,
    this.pauseFiltersOnSearch = true,
    this.activeOnly = false,
  });

  final String? categoryFilter;
  final StockFilter stockFilter;
  final ProductSort productSort;
  final PriceRange? priceRange;
  final String searchQuery;
  final int lowStockThreshold;
  final bool pauseFiltersOnSearch;

  /// When true, only [Product.isActive] products are kept (sale catalog).
  final bool activeOnly;

  @override
  List<Object?> get props => [
    categoryFilter,
    stockFilter,
    productSort,
    priceRange,
    searchQuery,
    lowStockThreshold,
    pauseFiltersOnSearch,
    activeOnly,
  ];
}

/// Single catalog filter pipeline — used by [ProductState.filteredProducts]
/// and sale filter sheet preview counts.
List<Product> applyProductListFilters(
  List<Product> products,
  ProductListFilterSpec spec,
) {
  final rawQuery = spec.searchQuery.trim();
  if (rawQuery.isNotEmpty && spec.pauseFiltersOnSearch) {
    var hits = matchProductList(products, rawQuery);
    if (spec.activeOnly) {
      hits = hits.where((p) => p.isActive).toList();
    }
    return hits;
  }

  var result = List<Product>.of(products);
  if (spec.activeOnly) {
    result = result.where((p) => p.isActive).toList();
  }

  final category = spec.categoryFilter;
  if (category != null) {
    if (category == kNoCategoryFilter) {
      result = result.where((p) => p.categoryId == null).toList();
    } else {
      result = result.where((p) => p.categoryId == category).toList();
    }
  }

  if (spec.stockFilter == StockFilter.lowStock) {
    final threshold = spec.lowStockThreshold < 1 ? 1 : spec.lowStockThreshold;
    result = result
        .where((p) => p.trackStock && p.stock > 0 && p.stock <= threshold)
        .toList();
  } else if (spec.stockFilter == StockFilter.outOfStock) {
    result = result.where((p) => p.trackStock && p.stock == 0).toList();
  }

  final range = spec.priceRange?.normalized();
  if (range != null && range.isActive) {
    final min = range.min;
    final max = range.max;
    if (min != null) {
      result = result.where((p) => p.price >= min).toList();
    }
    if (max != null) {
      result = result.where((p) => p.price <= max).toList();
    }
  }

  if (rawQuery.isNotEmpty) {
    // Keep filters, then ranked matches (includeInactive so caller can
    // still apply isActive via [activeOnly] or afterward).
    result = matchProductList(result, rawQuery, includeInactive: true);
  } else {
    switch (spec.productSort) {
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
  }
  return result;
}
