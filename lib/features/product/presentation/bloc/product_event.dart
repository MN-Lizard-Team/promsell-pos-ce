import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductsSubscribed extends ProductEvent {
  const ProductsSubscribed();
}

class ProductAdded extends ProductEvent {
  const ProductAdded({
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    this.cost,
    required this.stock,
    this.categoryId,
    this.imageUrl,
    this.imagePath,
    this.imageThumbnailPath,
    this.trackStock = true,
    this.isActive = true,
    this.description,
    this.brand,
    this.unit,
    this.supplier,
    this.isRecommended = false,
    this.optionGroups = const [],
  });
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double? cost;
  final int stock;
  final String? categoryId;
  final String? imageUrl;
  final String? imagePath;
  final String? imageThumbnailPath;
  final bool trackStock;
  final bool isActive;
  final String? description;
  final String? brand;
  final String? unit;
  final String? supplier;
  final bool isRecommended;
  final List<ProductOptionGroup> optionGroups;

  @override
  List<Object?> get props => [
    name,
    sku,
    barcode,
    price,
    cost,
    stock,
    categoryId,
    imageUrl,
    imagePath,
    imageThumbnailPath,
    trackStock,
    isActive,
    description,
    brand,
    unit,
    supplier,
    isRecommended,
    optionGroups,
  ];
}

class ProductUpdated extends ProductEvent {
  const ProductUpdated(this.product, {this.optionGroups});
  final Product product;
  final List<ProductOptionGroup>? optionGroups;

  @override
  List<Object?> get props => [product, optionGroups];
}

class ProductDeleted extends ProductEvent {
  const ProductDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Restores a soft-deleted product (undo delete).
class ProductRestored extends ProductEvent {
  const ProductRestored(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ProductSearchChanged extends ProductEvent {
  const ProductSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class ProductCategoryFilterChanged extends ProductEvent {
  const ProductCategoryFilterChanged(this.category);
  final String? category;

  @override
  List<Object?> get props => [category];
}

class BarcodesBatchGenerated extends ProductEvent {
  const BarcodesBatchGenerated({required this.prefix});
  final String prefix;

  @override
  List<Object?> get props => [prefix];
}

/// Clears [ProductState.batchResultMessage] after UI has shown the snack.
class ProductBatchResultConsumed extends ProductEvent {
  const ProductBatchResultConsumed();
}

class ProductStockFilterChanged extends ProductEvent {
  const ProductStockFilterChanged(this.filter);
  final StockFilter filter;

  @override
  List<Object?> get props => [filter];
}

class ProductSortChanged extends ProductEvent {
  const ProductSortChanged(this.sort);
  final ProductSort sort;

  @override
  List<Object?> get props => [sort];
}

class ProductPriceRangeChanged extends ProductEvent {
  const ProductPriceRangeChanged(this.priceRange);
  final PriceRange? priceRange;

  @override
  List<Object?> get props => [priceRange];
}

/// Atomic stock + sort + price apply (single emit) for sale filter sheet.
///
/// Category is intentionally omitted — sale chrome chips own category.
class ProductListFiltersApplied extends ProductEvent {
  const ProductListFiltersApplied({
    required this.stockFilter,
    required this.productSort,
    this.priceRange,
  });

  final StockFilter stockFilter;
  final ProductSort productSort;
  final PriceRange? priceRange;

  @override
  List<Object?> get props => [stockFilter, productSort, priceRange];
}

class ProductTabChanged extends ProductEvent {
  const ProductTabChanged(this.tab);
  final ProductTabFilter tab;

  @override
  List<Object?> get props => [tab];
}

class ProductsImported extends ProductEvent {
  const ProductsImported(this.rows);
  final List<CsvProductRow> rows;

  @override
  List<Object?> get props => [rows];
}

class ProductFiltersCleared extends ProductEvent {
  const ProductFiltersCleared();
}

/// Which shell tab is consuming shared [ProductBloc] filters.
enum ProductSurface { catalog, sale }

/// Switches filter snapshot between product list and sale catalog.
class ProductSurfaceEntered extends ProductEvent {
  const ProductSurfaceEntered(this.surface);
  final ProductSurface surface;

  @override
  List<Object?> get props => [surface];
}
