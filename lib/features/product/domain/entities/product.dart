import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

const Object _unset = Object();

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    this.cost = Money.zero,
    required this.stock,
    this.categoryId,
    this.imageUrl,
    this.imagePath,
    this.imageThumbnailPath,
    this.barcodeImagePath,
    this.description,
    this.brand,
    this.unit,
    this.supplier,
    this.isRecommended = false,
    required this.isActive,
    this.trackStock = true,
    this.optionGroups = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final Money price;
  final Money cost;
  final int stock;
  final String? categoryId;
  final String? imageUrl;
  final String? imagePath;
  final String? imageThumbnailPath;
  final String? barcodeImagePath;
  final String? description;
  final String? brand;
  final String? unit;
  final String? supplier;
  final bool isRecommended;
  final bool isActive;
  final bool trackStock;
  final List<ProductOptionGroup> optionGroups;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInStock => !trackStock || stock > 0;

  /// Deprecated alias for [categoryId].
  String? get category => categoryId;

  Product copyWith({
    String? id,
    String? name,
    Object? sku = _unset,
    Object? barcode = _unset,
    Money? price,
    Object? cost = _unset,
    int? stock,
    Object? categoryId = _unset,
    Object? imageUrl = _unset,
    Object? imagePath = _unset,
    Object? imageThumbnailPath = _unset,
    Object? barcodeImagePath = _unset,
    Object? description = _unset,
    Object? brand = _unset,
    Object? unit = _unset,
    Object? supplier = _unset,
    bool? isRecommended,
    bool? isActive,
    bool? trackStock,
    List<ProductOptionGroup>? optionGroups,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: identical(sku, _unset) ? this.sku : sku as String?,
      barcode: identical(barcode, _unset) ? this.barcode : barcode as String?,
      price: price ?? this.price,
      cost: identical(cost, _unset)
          ? this.cost
          : (cost as Money?) ?? Money.zero,
      stock: stock ?? this.stock,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      imageUrl: identical(imageUrl, _unset)
          ? this.imageUrl
          : imageUrl as String?,
      imagePath: identical(imagePath, _unset)
          ? this.imagePath
          : imagePath as String?,
      imageThumbnailPath: identical(imageThumbnailPath, _unset)
          ? this.imageThumbnailPath
          : imageThumbnailPath as String?,
      barcodeImagePath: identical(barcodeImagePath, _unset)
          ? this.barcodeImagePath
          : barcodeImagePath as String?,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      brand: identical(brand, _unset) ? this.brand : brand as String?,
      unit: identical(unit, _unset) ? this.unit : unit as String?,
      supplier: identical(supplier, _unset)
          ? this.supplier
          : supplier as String?,
      isRecommended: isRecommended ?? this.isRecommended,
      isActive: isActive ?? this.isActive,
      trackStock: trackStock ?? this.trackStock,
      optionGroups: optionGroups ?? this.optionGroups,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
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
    barcodeImagePath,
    description,
    brand,
    unit,
    supplier,
    isRecommended,
    isActive,
    trackStock,
    optionGroups,
    createdAt,
    updatedAt,
  ];
}
