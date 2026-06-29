import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
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
  ];
}

class ProductUpdated extends ProductEvent {
  const ProductUpdated(this.product);
  final Product product;

  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductEvent {
  const ProductDeleted(this.id);
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
