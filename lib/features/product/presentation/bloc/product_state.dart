import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/import_products.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_list_filters.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_search.dart';

export 'package:promsell_pos_ce/features/product/domain/utils/product_list_filters.dart'
    show
        PriceRange,
        ProductListFilterSpec,
        ProductSort,
        StockFilter,
        applyProductListFilters,
        kNoCategoryFilter;

const Object _unset = Object();

enum ProductStatus { initial, loading, success, failure }

enum ProductSaveStatus { idle, saving, saved, error }

/// Isolated from [ProductStatus] so catalog stream updates don't race CSV import UI.
enum ProductImportStatus { idle, importing, success, failure }

enum ProductTabFilter { all, category, stock }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.totalProductCount = 0,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.hasMoreSearchResults = false,
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
    this.lastDeletedProductId,
    this.lastDeletedProductName,
  });

  final ProductStatus status;
  final List<Product> products;

  /// Total non-deleted product count (from DB, not products.length).
  /// Used for "Showing X of Y" indicator and pagination decisions.
  final int totalProductCount;
  final String searchQuery;

  /// DB-backed search hits ([ProductSearchChanged] against the full catalog,
  /// not just the capped loaded set). Empty unless the catalog is capped and a
  /// search ran. Rendered by sale catalog instead of [filteredProducts].
  final List<Product> searchResults;

  /// True while a DB search page (search or load-more) is in flight.
  final bool isSearching;

  /// True when more DB search pages exist beyond [searchResults].
  final bool hasMoreSearchResults;
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

  /// ID + name of the last soft-deleted product (for Undo snack).
  final String? lastDeletedProductId;
  final String? lastDeletedProductName;

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
  ///
  /// Delegates to [applyProductListFilters] (single pipeline with sheet preview).
  List<Product> filteredProducts({
    int lowStockThreshold = 5,
    bool pauseFiltersOnSearch = true,
    bool activeOnly = false,
  }) {
    return applyProductListFilters(
      products,
      ProductListFilterSpec(
        categoryFilter: categoryFilter,
        stockFilter: stockFilter,
        productSort: productSort,
        priceRange: priceRange,
        searchQuery: searchQuery,
        lowStockThreshold: lowStockThreshold,
        pauseFiltersOnSearch: pauseFiltersOnSearch,
        activeOnly: activeOnly,
      ),
    );
  }

  /// Backward-compatible getter (threshold 5). Prefer [filteredProducts].
  List<Product> get filtered => filteredProducts();

  /// True when list-level filters (not search) are active.
  bool get hasListFiltersActive =>
      categoryFilter != null ||
      stockFilter != StockFilter.all ||
      (priceRange?.isActive ?? false);

  /// True when there are more products to load (loaded < total).
  bool get hasMoreProducts => products.length < totalProductCount;

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
    int? totalProductCount,
    String? searchQuery,
    List<Product>? searchResults,
    bool? isSearching,
    bool? hasMoreSearchResults,
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
    Object? lastDeletedProductId = _unset,
    Object? lastDeletedProductName = _unset,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      totalProductCount: totalProductCount ?? this.totalProductCount,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      hasMoreSearchResults: hasMoreSearchResults ?? this.hasMoreSearchResults,
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
      lastDeletedProductId: identical(lastDeletedProductId, _unset)
          ? this.lastDeletedProductId
          : lastDeletedProductId as String?,
      lastDeletedProductName: identical(lastDeletedProductName, _unset)
          ? this.lastDeletedProductName
          : lastDeletedProductName as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    totalProductCount,
    searchQuery,
    searchResults,
    isSearching,
    hasMoreSearchResults,
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
    lastDeletedProductId,
    lastDeletedProductName,
  ];
}
