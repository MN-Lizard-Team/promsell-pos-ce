import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/batch_generate_barcodes.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
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
    required AddProduct addProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required BatchGenerateBarcodes batchGenerateBarcodes,
    required ImportProducts importProducts,
  }) : _getProducts = getProducts,
       _addProduct = addProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       _batchGenerateBarcodes = batchGenerateBarcodes,
       _importProducts = importProducts,
       super(const ProductState()) {
    on<ProductsSubscribed>(_onSubscribed);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<_ProductsError>(_onProductsError);
    on<ProductAdded>(_onAdded);
    on<ProductUpdated>(_onUpdated);
    on<ProductDeleted>(_onDeleted);
    on<ProductSearchChanged>(_onSearchChanged);
    on<ProductCategoryFilterChanged>(_onCategoryFilterChanged);
    on<ProductStockFilterChanged>(_onStockFilterChanged);
    on<ProductSortChanged>(_onSortChanged);
    on<ProductPriceRangeChanged>(_onPriceRangeChanged);
    on<BarcodesBatchGenerated>(_onBatchGenerated);
    on<ProductBatchResultConsumed>(_onBatchResultConsumed);
    on<ProductTabChanged>(_onTabChanged);
    on<ProductsImported>(_onImported);
    on<ProductFiltersCleared>(_onFiltersCleared);
    on<ProductSurfaceEntered>(_onSurfaceEntered);
  }

  final GetProducts _getProducts;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final BatchGenerateBarcodes _batchGenerateBarcodes;
  final ImportProducts _importProducts;
  StreamSubscription<List<Product>>? _sub;

  /// Per-surface filter snapshots so Sale ↔ Products don't leak filters.
  final Map<ProductSurface, _FilterSnapshot> _filterSnapshots = {};
  ProductSurface? _activeSurface;

  Future<void> _onSubscribed(
    ProductsSubscribed event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    await _sub?.cancel();
    _sub = _getProducts().listen(
      (products) => add(_ProductsUpdated(products)),
      onError: (Object e) => add(_ProductsError(e.toString())),
    );
  }

  void _onProductsUpdated(_ProductsUpdated event, Emitter<ProductState> emit) {
    emit(
      state.copyWith(
        status: ProductStatus.success,
        products: event.products,
        error: null,
        saveStatus: ProductSaveStatus.idle,
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
      await _deleteProduct(event.id);
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.saved,
          products: state.products.where((p) => p.id != event.id).toList(),
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

  void _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query.trim()));
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
