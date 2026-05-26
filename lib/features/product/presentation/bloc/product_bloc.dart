import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
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
  }) : _getProducts = getProducts,
       _addProduct = addProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct,
       super(const ProductState()) {
    on<ProductsSubscribed>(_onSubscribed);
    on<_ProductsUpdated>(_onProductsUpdated);
    on<_ProductsError>(_onProductsError);
    on<ProductAdded>(_onAdded);
    on<ProductUpdated>(_onUpdated);
    on<ProductDeleted>(_onDeleted);
    on<ProductSearchChanged>(_onSearchChanged);
  }

  final GetProducts _getProducts;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  StreamSubscription<List<Product>>? _sub;

  void _onSubscribed(ProductsSubscribed event, Emitter<ProductState> emit) {
    emit(state.copyWith(status: ProductStatus.loading));
    _sub?.cancel();
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
        price: event.price,
        stock: event.stock,
        category: event.category,
        imageUrl: event.imageUrl,
      );
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

  Future<void> _onUpdated(
    ProductUpdated event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(saveStatus: ProductSaveStatus.saving));
    try {
      await _updateProduct(event.product);
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

  Future<void> _onDeleted(
    ProductDeleted event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _deleteProduct(event.id);
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

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
