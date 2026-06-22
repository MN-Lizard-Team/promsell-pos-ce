import 'package:equatable/equatable.dart';

const Object _unset = Object();

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    this.cost = 0.0,
    required this.stock,
    this.categoryId,
    this.imageUrl,
    this.imagePath,
    this.imageThumbnailPath,
    required this.isActive,
    this.trackStock = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double cost;
  final int stock;
  final String? categoryId;
  final String? imageUrl;
  final String? imagePath;
  final String? imageThumbnailPath;
  final bool isActive;
  final bool trackStock;
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
    double? price,
    double? cost,
    int? stock,
    Object? categoryId = _unset,
    Object? imageUrl = _unset,
    Object? imagePath = _unset,
    Object? imageThumbnailPath = _unset,
    bool? isActive,
    bool? trackStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: identical(sku, _unset) ? this.sku : sku as String?,
      barcode: identical(barcode, _unset) ? this.barcode : barcode as String?,
      price: price ?? this.price,
      cost: cost ?? this.cost,
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
      isActive: isActive ?? this.isActive,
      trackStock: trackStock ?? this.trackStock,
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
    isActive,
    trackStock,
    createdAt,
    updatedAt,
  ];
}
