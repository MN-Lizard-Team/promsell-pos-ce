import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/batch_generate_barcodes.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
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
  }) : _getProducts = getProducts,
       _addProduct = addProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       _batchGenerateBarcodes = batchGenerateBarcodes,
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
    on<BarcodesBatchGenerated>(_onBatchGenerated);
  }

  final GetProducts _getProducts;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final BatchGenerateBarcodes _batchGenerateBarcodes;
  StreamSubscription<List<Product>>? _sub;

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
        errorMessage: null,
        saveStatus: ProductSaveStatus.idle,
      ),
    );
  }

  void _onProductsError(_ProductsError event, Emitter<ProductState> emit) {
    emit(
      state.copyWith(
        status: ProductStatus.failure,
        errorMessage: event.message,
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
      );
      emit(state.copyWith(saveStatus: ProductSaveStatus.saved));
    } on DuplicateBarcodeException catch (_) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          errorMessage: 'duplicateBarcode',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          errorMessage: e.toString(),
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
      await _updateProduct(event.product);
      emit(state.copyWith(saveStatus: ProductSaveStatus.saved));
    } on DuplicateBarcodeException catch (_) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          errorMessage: 'duplicateBarcode',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          errorMessage: e.toString(),
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
      emit(state.copyWith(saveStatus: ProductSaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: ProductSaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
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
    final newFilter = state.stockFilter == event.filter
        ? StockFilter.all
        : event.filter;
    emit(state.copyWith(stockFilter: newFilter));
  }

  Future<void> _onBatchGenerated(
    BarcodesBatchGenerated event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(batchResultMessage: null));
    try {
      final count = await _batchGenerateBarcodes(prefix: event.prefix);
      emit(
        state.copyWith(
          status: ProductStatus.success,
          batchResultMessage: count.toString(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
          batchResultMessage: null,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
