import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/core/exceptions/optimistic_lock_exception.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_page.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/batch_generate_barcodes.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/restore_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products_page.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/import_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';

class _ProductsUpdated extends ProductEvent {
  const _ProductsUpdated(this.products);
  final List<Product> products;
  @override
  List<Object?> get props => [products];
}

class _ProductsError extends ProductEvent {
  const _ProductsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    required GetProducts getProducts,
    required GetProductCount getProductCount,
    required AddProduct addProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required RestoreProduct restoreProduct,
    required BatchGenerateBarcodes batchGenerateBarcodes,
    required ImportProducts importProducts,
    SearchProductsPage? searchProductsPage,
  }) : _getProducts = getProducts,
       _getProductCount = getProductCount,
       _addProduct = addProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       _restoreProduct = restoreProduct,
       _batchGenerateBarcodes = batchGenerateBarcodes,
       _importProducts = importProducts,
       _searchProductsPage = searchProductsPage,
       super(const ProductState()) {
    on<ProductsSubscribed>(_onSubscribed);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<_ProductsError>(_onProductsError);
    on<ProductAdded>(_onAdded);
    on<ProductUpdated>(_onUpdated);
    on<ProductDeleted>(_onDeleted);
    on<ProductRestored>(_onRestored);
    // restartable: rapid keystrokes cancel in-flight search page fetches.
    on<ProductSearchChanged>(_onSearchChanged, transformer: restartable());
    on<ProductLoadMore>(_onLoadMore, transformer: droppable());
    on<ProductCategoryFilterChanged>(_onCategoryFilterChanged);
    on<ProductStockFilterChanged>(_onStockFilterChanged);
    on<ProductSortChanged>(_onSortChanged);
    on<ProductPriceRangeChanged>(_onPriceRangeChanged);
    on<ProductListFiltersApplied>(_onListFiltersApplied);
    on<BarcodesBatchGenerated>(_onBatchGenerated);
    on<ProductBatchResultConsumed>(_onBatchResultConsumed);
    on<ProductTabChanged>(_onTabChanged);
    on<ProductsImported>(_onImported);
    on<ProductFiltersCleared>(_onFiltersCleared);
    on<ProductSurfaceEntered>(_onSurfaceEntered);
  }

  final GetProducts _getProducts;
  final GetProductCount _getProductCount;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final RestoreProduct _restoreProduct;
  final BatchGenerateBarcodes _batchGenerateBarcodes;
  final ImportProducts _importProducts;

  /// DB-backed search over the full catalog. Nullable so existing call sites
  /// (DI module, tests) keep compiling; when null the search handler degrades
  /// to client-side filtering over the loaded set only.
  final SearchProductsPage? _searchProductsPage;
  StreamSubscription<List<Product>>? _sub;

  /// Page size for DB search fetches (search + load-more).
  static const int _searchPageSize = 100;

  /// Per-surface filter snapshots so Sale ↔ Products don't leak filters.
  final Map<ProductSurface, _FilterSnapshot> _filterSnapshots = {};
  ProductSurface? _activeSurface;

  /// Catalog watch cap — beyond this the stream LIMITs to
  /// [_paginationThreshold] rows to bound memory. Search is NOT capped:
  /// when the loaded set is smaller than [ProductState.totalProductCount],
  /// [ProductSearchChanged] additionally queries the DB via
  /// [SearchProductsPage] (ranked SQL LIKE) into
  /// [ProductState.searchResults], and [ProductLoadMore] appends further
  /// cursor pages while [ProductState.hasMoreSearchResults] is true.
  /// Uncapped catalogs keep pure client-side filtering (no extra queries).
  static const int _paginationThreshold = 500;

  Future<void> _onSubscribed(
    ProductsSubscribed event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    await _sub?.cancel();

    try {
      final totalCount = await _getProductCount();
      final limit = totalCount > _paginationThreshold
          ? _paginationThreshold
          : null;

      _sub = _getProducts(limit: limit).listen(
        (products) => add(_ProductsUpdated(products)),
        onError: (Object e) => add(_ProductsError(e.toString())),
        onDone: () => _sub = null,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          error: DatabaseError(e.toString(), operation: 'load_products'),
        ),
      );
    }
  }

  void _onProductsUpdated(_ProductsUpdated event, Emitter<ProductState> emit) {
    // Preserve saveStatus when saving/saved so stream updates don't
    // overwrite the save result before form listeners can react.
    final preserveSave =
        state.saveStatus == ProductSaveStatus.saving ||
        state.saveStatus == ProductSaveStatus.saved;
    // Update totalCount if we loaded all products (no pagination).
    // When paginated, products.length is the loaded count, not total.
    final newTotal = event.products.length > state.totalProductCount
        ? event.products.length
        : state.totalProductCount;
    emit(
      state.copyWith(
        status: ProductStatus.success,
        products: event.products,
        totalProductCount: newTotal,
        error: null,
        saveStatus: preserveSave ? null : ProductSaveStatus.idle,
      ),
    );
  }

  void _onProductsError(_ProductsError event, Emitter<ProductState> emit) {
    emit(
      state.copyWith(
        status: ProductStatus.failure,
        error: UnknownError(event.message),
      ),
    );
  }

  Future<void> _onAdded(ProductAdded event, Emitter<ProductState> emit) async {
    emit(state.copyWith(saveStatus: ProductSaveStatus.saving));
    try {
      await _addProduct(
        name: event.name,
        sku: event.sku,
        barcode: event.barcode,
        price: event.price,
        cost: event.cost,
        stock: event.stock,
        categoryId: event.categoryId,
        imageUrl: event.imageUrl,
        imagePath: event.imagePath,
        imageThumbnailPath: event.imageThumbnailPath,
        trackStock: event.trackStock,
        isActive: event.isActive,
        description: event.description,
        brand: event.brand,
        unit: event.unit,
        supplier: event.supplier,
        isRecommended: event.isRecommended,
        optionGroups: event.optionGroups,
      );
      emit(state.copyWith(saveStatus: ProductSaveStatus.saved));
    } on DuplicateBarcodeException catch (_) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          error: const BusinessRuleError('DuplicateBarcode'),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          error: DatabaseError(e.toString(), operation: 'insert'),
        ),
      );
    }
  }

  Future<void> _onUpdated(
    ProductUpdated event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(saveStatus: ProductSaveStatus.saving));
    try {
      if (event.optionGroups == null) {
        await _updateProduct(event.product);
      } else {
        await _updateProduct(event.product, optionGroups: event.optionGroups);
      }
      // Merge into list immediately so preview/list don't wait on the
      // watch stream (race with form pop after save).
      final updated = event.optionGroups != null
          ? event.product.copyWith(optionGroups: event.optionGroups)
          : event.product;
      final products = _replaceProduct(state.products, updated);
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.saved,
          products: products,
          status: ProductStatus.success,
        ),
      );
    } on DuplicateBarcodeException catch (_) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          error: const BusinessRuleError('DuplicateBarcode'),
        ),
      );
    } on OptimisticLockException catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          error: BusinessRuleError('OptimisticLock: ${e.entityId}'),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          error: DatabaseError(e.toString(), operation: 'update'),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    ProductDeleted event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(saveStatus: ProductSaveStatus.saving));
    try {
      // Capture product name before delete for undo snack.
      final product = state.products.firstWhere(
        (p) => p.id == event.id,
        orElse: () => Product(
          id: event.id,
          name: '',
          price: Money.zero,
          stock: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await _deleteProduct(event.id);
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.saved,
          products: state.products.where((p) => p.id != event.id).toList(),
          lastDeletedProductId: event.id,
          lastDeletedProductName: product.name,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          error: DatabaseError(e.toString(), operation: 'delete'),
        ),
      );
    }
  }

  Future<void> _onRestored(
    ProductRestored event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _restoreProduct(event.id);
      emit(
        state.copyWith(
          lastDeletedProductId: null,
          lastDeletedProductName: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: DatabaseError(e.toString(), operation: 'restore'),
        ),
      );
    }
  }

  List<Product> _replaceProduct(List<Product> products, Product updated) {
    final next = <Product>[];
    var found = false;
    for (final p in products) {
      if (p.id == updated.id) {
        next.add(updated);
        found = true;
      } else {
        next.add(p);
      }
    }
    if (!found) next.add(updated);
    return next;
  }

  Future<void> _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) async {
    final query = event.query.trim();
    // Capped catalog: loaded set < total → client-side filtering would
    // silently miss everything beyond the cap, so search the DB instead.
    final capped = state.products.length < state.totalProductCount;

    if (query.isEmpty || !capped || _searchProductsPage == null) {
      emit(
        state.copyWith(
          searchQuery: query,
          searchResults: const [],
          isSearching: false,
          hasMoreSearchResults: false,
        ),
      );
      return;
    }

    emit(state.copyWith(searchQuery: query, isSearching: true, error: null));
    try {
      final page = await _searchProductsPage(
        query: query,
        activeOnly: true,
        pageSize: _searchPageSize,
      );
      if (state.searchQuery != query) return; // superseded mid-flight
      emit(
        state.copyWith(
          isSearching: false,
          searchResults: page.products,
          hasMoreSearchResults: page.hasMore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearching: false,
          status: ProductStatus.failure,
          error: DatabaseError(e.toString(), operation: 'search_products'),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    ProductLoadMore event,
    Emitter<ProductState> emit,
  ) async {
    final query = state.searchQuery;
    final results = state.searchResults;
    final search = _searchProductsPage;
    if (query.isEmpty ||
        results.isEmpty ||
        !state.hasMoreSearchResults ||
        search == null) {
      return;
    }

    // Cursor shape: (createdAt, id) of the last received row — the repo
    // pages by createdAt DESC, id DESC.
    final last = results.last;
    final cursor = ProductCursor(createdAt: last.createdAt, id: last.id);
    emit(state.copyWith(isSearching: true));
    try {
      final page = await search(
        query: query,
        cursor: cursor,
        activeOnly: true,
        pageSize: _searchPageSize,
      );
      if (state.searchQuery != query) return; // a newer search superseded us
      final knownIds = results.map((p) => p.id).toSet();
      final merged = [
        ...results,
        ...page.products.where((p) => !knownIds.contains(p.id)),
      ];
      emit(
        state.copyWith(
          isSearching: false,
          searchResults: merged,
          hasMoreSearchResults: page.hasMore,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSearching: false,
          status: ProductStatus.failure,
          error: DatabaseError(e.toString(), operation: 'load_more_search'),
        ),
      );
    }
  }

  void _onCategoryFilterChanged(
    ProductCategoryFilterChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(categoryFilter: event.category));
  }

  void _onStockFilterChanged(
    ProductStockFilterChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(stockFilter: event.filter));
  }

  void _onSortChanged(ProductSortChanged event, Emitter<ProductState> emit) {
    emit(state.copyWith(productSort: event.sort));
  }

  void _onPriceRangeChanged(
    ProductPriceRangeChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(priceRange: event.priceRange));
  }

  void _onListFiltersApplied(
    ProductListFiltersApplied event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        stockFilter: event.stockFilter,
        productSort: event.productSort,
        priceRange: event.priceRange,
      ),
    );
  }

  Future<void> _onBatchGenerated(
    BarcodesBatchGenerated event,
    Emitter<ProductState> emit,
  ) async {
    if (state.isBatchGenerating) return;
    emit(
      state.copyWith(
        isBatchGenerating: true,
        batchResultMessage: null,
        error: null,
      ),
    );
    try {
      final count = await _batchGenerateBarcodes(prefix: event.prefix);
      // Ensure catalog stream is live so list/settings see new barcodes.
      if (_sub == null) {
        add(const ProductsSubscribed());
      }
      emit(
        state.copyWith(
          status: ProductStatus.success,
          isBatchGenerating: false,
          batchResultMessage: count.toString(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          isBatchGenerating: false,
          error: DatabaseError(e.toString(), operation: 'barcode_generation'),
          batchResultMessage: null,
        ),
      );
    }
  }

  void _onBatchResultConsumed(
    ProductBatchResultConsumed event,
    Emitter<ProductState> emit,
  ) {
    if (state.batchResultMessage == null) return;
    emit(state.copyWith(batchResultMessage: null));
  }

  void _onTabChanged(ProductTabChanged event, Emitter<ProductState> emit) {
    switch (event.tab) {
      case ProductTabFilter.all:
        // All resets category + stock only (search/sort/price stay).
        emit(
          state.copyWith(
            selectedTab: event.tab,
            categoryFilter: null,
            stockFilter: StockFilter.all,
          ),
        );
      case ProductTabFilter.category:
      case ProductTabFilter.stock:
        // Highlight tab only — do not clear the sibling filter.
        emit(state.copyWith(selectedTab: event.tab));
    }
  }

  Future<void> _onImported(
    ProductsImported event,
    Emitter<ProductState> emit,
  ) async {
    // Use importStatus only — never ProductStatus.loading, so catalog stream
    // updates cannot race the CSV import dialog listener.
    emit(
      state.copyWith(
        importStatus: ProductImportStatus.importing,
        importResult: null,
      ),
    );
    try {
      final result = await _importProducts(event.rows);
      emit(
        state.copyWith(
          importStatus: ProductImportStatus.success,
          importResult: result,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          importStatus: ProductImportStatus.failure,
          error: DatabaseError(e.toString(), operation: 'import'),
        ),
      );
    }
  }

  void _onFiltersCleared(
    ProductFiltersCleared event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: '',
        searchResults: const [],
        isSearching: false,
        hasMoreSearchResults: false,
        categoryFilter: null,
        stockFilter: StockFilter.all,
        productSort: ProductSort.default_,
        selectedTab: ProductTabFilter.all,
        priceRange: null,
      ),
    );
    if (_activeSurface != null) {
      _filterSnapshots[_activeSurface!] = _FilterSnapshot.fromState(state);
    }
  }

  void _onSurfaceEntered(
    ProductSurfaceEntered event,
    Emitter<ProductState> emit,
  ) {
    if (_activeSurface == event.surface) return;

    if (_activeSurface != null) {
      _filterSnapshots[_activeSurface!] = _FilterSnapshot.fromState(state);
    }

    _activeSurface = event.surface;
    final snap =
        _filterSnapshots[event.surface] ??
        _FilterSnapshot.defaultsFor(event.surface);
    emit(snap.apply(state));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

class _FilterSnapshot {
  const _FilterSnapshot({
    required this.searchQuery,
    required this.categoryFilter,
    required this.stockFilter,
    required this.productSort,
    required this.priceRange,
    required this.selectedTab,
  });

  final String searchQuery;
  final String? categoryFilter;
  final StockFilter stockFilter;
  final ProductSort productSort;
  final PriceRange? priceRange;
  final ProductTabFilter selectedTab;

  factory _FilterSnapshot.fromState(ProductState s) => _FilterSnapshot(
    searchQuery: s.searchQuery,
    categoryFilter: s.categoryFilter,
    stockFilter: s.stockFilter,
    productSort: s.productSort,
    priceRange: s.priceRange,
    selectedTab: s.selectedTab,
  );

  factory _FilterSnapshot.defaultsFor(ProductSurface surface) =>
      const _FilterSnapshot(
        searchQuery: '',
        categoryFilter: null,
        stockFilter: StockFilter.all,
        productSort: ProductSort.default_,
        priceRange: null,
        selectedTab: ProductTabFilter.all,
      );

  ProductState apply(ProductState base) => base.copyWith(
    searchQuery: searchQuery,
    categoryFilter: categoryFilter,
    stockFilter: stockFilter,
    productSort: productSort,
    priceRange: priceRange,
    selectedTab: selectedTab,
  );
}
