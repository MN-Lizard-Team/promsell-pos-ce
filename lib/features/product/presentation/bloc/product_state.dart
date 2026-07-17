import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/import_products.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_search.dart';

const Object _unset = Object();

enum ProductStatus { initial, loading, success, failure }

enum ProductSaveStatus { idle, saving, saved, error }

/// Isolated from [ProductStatus] so catalog stream updates don't race CSV import UI.
enum ProductImportStatus { idle, importing, success, failure }

const String kNoCategoryFilter = '__none__';

enum StockFilter { all, lowStock, outOfStock }

enum ProductTabFilter { all, category, stock }

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
    this.selectedTab = ProductTabFilter.all,
    this.error,
    this.saveStatus = ProductSaveStatus.idle,
    this.batchResultMessage,
    this.isBatchGenerating = false,
    this.importResult,
    this.importStatus = ProductImportStatus.idle,
  });

  final ProductStatus status;
  final List<Product> products;
  final String searchQuery;
  final String? categoryFilter;
  final StockFilter stockFilter;
  final ProductSort productSort;
  final PriceRange? priceRange;
  final ProductTabFilter selectedTab;
  final AppError? error;
  final ProductSaveStatus saveStatus;

  /// Count of barcodes written by the last batch run (`"0"` allowed). Null = idle.
  final String? batchResultMessage;

  /// True while [BarcodesBatchGenerated] is in flight (not catalog loading).
  final bool isBatchGenerating;
  final ProductImportResult? importResult;
  final ProductImportStatus importStatus;

  String? get errorMessage {
    final e = error;
    if (e == null) return null;
    return switch (e) {
      ValidationError(:final message) => message,
      NotFoundError(:final resource) => resource,
      BusinessRuleError(:final rule) => rule,
      DatabaseError(:final message) => message,
      NetworkError(:final message) => message,
      FileSystemError(:final message) => message,
      PermissionDeniedError(:final permission) => permission,
      UnknownError(:final message) => message,
    };
  }

  /// Filtered catalog. Pass [lowStockThreshold] from settings (default 5 for
  /// callers that have not migrated yet).
  ///
  /// When [searchQuery] is non-empty and [pauseFiltersOnSearch] is true
  /// (catalog list default), uses ranked [matchProductList] only — same as
  /// full search page (category/stock/price filters paused).
  ///
  /// Sale passes [pauseFiltersOnSearch]: false so category filters stay on,
  /// then matches are ranked within the filtered set.
  List<Product> filteredProducts({
    int lowStockThreshold = 5,
    bool pauseFiltersOnSearch = true,
  }) {
    final rawQuery = searchQuery.trim();
    if (rawQuery.isNotEmpty && pauseFiltersOnSearch) {
      return matchProductList(products, rawQuery);
    }

    var result = List<Product>.of(products);
    if (categoryFilter != null) {
      if (categoryFilter == kNoCategoryFilter) {
        result = result.where((p) => p.categoryId == null).toList();
      } else {
        result = result.where((p) => p.categoryId == categoryFilter).toList();
      }
    }
    if (stockFilter == StockFilter.lowStock) {
      final threshold = lowStockThreshold < 1 ? 1 : lowStockThreshold;
      result = result
          .where((p) => p.trackStock && p.stock > 0 && p.stock <= threshold)
          .toList();
    } else if (stockFilter == StockFilter.outOfStock) {
      result = result.where((p) => p.trackStock && p.stock == 0).toList();
    }
    if (priceRange != null) {
      if (priceRange!.min != null) {
        result = result
            .where((p) => p.price.value >= priceRange!.min!)
            .toList();
      }
      if (priceRange!.max != null) {
        result = result
            .where((p) => p.price.value <= priceRange!.max!)
            .toList();
      }
    }
    if (rawQuery.isNotEmpty) {
      // Keep filters, then ranked matches only (includeInactive so sale can
      // still apply isActive itself).
      result = matchProductList(result, rawQuery, includeInactive: true);
    } else {
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
    }
    return result;
  }

  /// Backward-compatible getter (threshold 5). Prefer [filteredProducts].
  List<Product> get filtered => filteredProducts();

  /// True when list-level filters (not search) are active.
  bool get hasListFiltersActive =>
      categoryFilter != null ||
      stockFilter != StockFilter.all ||
      (priceRange?.isActive ?? false);

  /// Search-only matches (name / SKU / barcode). Ignores category, stock, price
  /// filters. Ranked via [matchProductList]; inactive excluded by default.
  List<Product> productsMatchingQuery([String? query]) {
    return matchProductList(products, query ?? searchQuery);
  }

  /// Ranked hits with match metadata (for chips / caps).
  List<ProductSearchMatch> productsMatchingQueryDetailed([String? query]) {
    return matchProducts(products, query ?? searchQuery);
  }

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? searchQuery,
    Object? categoryFilter = _unset,
    StockFilter? stockFilter,
    ProductSort? productSort,
    Object? priceRange = _unset,
    ProductTabFilter? selectedTab,
    Object? error = _unset,
    ProductSaveStatus? saveStatus,
    Object? batchResultMessage = _unset,
    bool? isBatchGenerating,
    Object? importResult = _unset,
    ProductImportStatus? importStatus,
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
      selectedTab: selectedTab ?? this.selectedTab,
      error: identical(error, _unset) ? this.error : error as AppError?,
      saveStatus: saveStatus ?? this.saveStatus,
      batchResultMessage: identical(batchResultMessage, _unset)
          ? this.batchResultMessage
          : batchResultMessage as String?,
      isBatchGenerating: isBatchGenerating ?? this.isBatchGenerating,
      importResult: identical(importResult, _unset)
          ? this.importResult
          : importResult as ProductImportResult?,
      importStatus: importStatus ?? this.importStatus,
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
    selectedTab,
    error,
    saveStatus,
    batchResultMessage,
    isBatchGenerating,
    importResult,
    importStatus,
  ];
}
