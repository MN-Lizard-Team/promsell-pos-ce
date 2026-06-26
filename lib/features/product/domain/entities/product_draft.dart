import 'package:equatable/equatable.dart';

class ProductDraft extends Equatable {
  const ProductDraft({
    this.name = '',
    this.price = '',
    this.stock = '0',
    this.sku = '',
    this.barcode = '',
    this.cost = '',
    this.categoryId,
    this.categoryName,
    this.imagePath,
    this.imageThumbnailPath,
    this.trackStock = true,
    this.isActive = true,
  });

  final String name;
  final String price;
  final String stock;
  final String sku;
  final String barcode;
  final String cost;
  final String? categoryId;
  final String? categoryName;
  final String? imagePath;
  final String? imageThumbnailPath;
  final bool trackStock;
  final bool isActive;

  bool get isEmpty =>
      name.isEmpty &&
      price.isEmpty &&
      sku.isEmpty &&
      barcode.isEmpty &&
      cost.isEmpty &&
      categoryId == null &&
      imagePath == null;

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'stock': stock,
    'sku': sku,
    'barcode': barcode,
    'cost': cost,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'imagePath': imagePath,
    'imageThumbnailPath': imageThumbnailPath,
    'trackStock': trackStock,
    'isActive': isActive,
  };

  factory ProductDraft.fromJson(Map<String, dynamic> json) => ProductDraft(
    name: json['name'] as String? ?? '',
    price: json['price'] as String? ?? '',
    stock: json['stock'] as String? ?? '0',
    sku: json['sku'] as String? ?? '',
    barcode: json['barcode'] as String? ?? '',
    cost: json['cost'] as String? ?? '',
    categoryId: json['categoryId'] as String?,
    categoryName: json['categoryName'] as String?,
    imagePath: json['imagePath'] as String?,
    imageThumbnailPath: json['imageThumbnailPath'] as String?,
    trackStock: json['trackStock'] as bool? ?? true,
    isActive: json['isActive'] as bool? ?? true,
  );

  ProductDraft copyWith({
    String? name,
    String? price,
    String? stock,
    String? sku,
    String? barcode,
    String? cost,
    String? categoryId,
    String? categoryName,
    String? imagePath,
    String? imageThumbnailPath,
    bool? trackStock,
    bool? isActive,
  }) {
    return ProductDraft(
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      cost: cost ?? this.cost,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imagePath: imagePath ?? this.imagePath,
      imageThumbnailPath: imageThumbnailPath ?? this.imageThumbnailPath,
      trackStock: trackStock ?? this.trackStock,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    name,
    price,
    stock,
    sku,
    barcode,
    cost,
    categoryId,
    categoryName,
    imagePath,
    imageThumbnailPath,
    trackStock,
    isActive,
  ];
}
