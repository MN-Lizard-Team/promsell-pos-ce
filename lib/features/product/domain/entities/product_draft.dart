import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

const Object _unset = Object();

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
    this.isRecommended = false,
    this.description = '',
    this.brand = '',
    this.unit = '',
    this.supplier = '',
    this.optionGroups = const [],
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
  final bool isRecommended;
  final String description;
  final String brand;
  final String unit;
  final String supplier;
  final List<ProductOptionGroup> optionGroups;

  bool get isEmpty =>
      name.isEmpty &&
      price.isEmpty &&
      sku.isEmpty &&
      barcode.isEmpty &&
      cost.isEmpty &&
      categoryId == null &&
      imagePath == null &&
      description.isEmpty &&
      brand.isEmpty &&
      unit.isEmpty &&
      supplier.isEmpty &&
      !isRecommended &&
      optionGroups.isEmpty;

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
    'isRecommended': isRecommended,
    'description': description,
    'brand': brand,
    'unit': unit,
    'supplier': supplier,
    'optionGroups': optionGroups.map((group) => group.toJson()).toList(),
  };

  factory ProductDraft.fromJson(Map<String, dynamic> json) {
    final optionGroupValues =
        json['optionGroups'] as List<dynamic>? ?? const [];
    return ProductDraft(
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
      isRecommended: json['isRecommended'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      supplier: json['supplier'] as String? ?? '',
      optionGroups: optionGroupValues
          .whereType<Map<String, dynamic>>()
          .map(ProductOptionGroup.fromJson)
          .toList(),
    );
  }

  ProductDraft copyWith({
    String? name,
    String? price,
    String? stock,
    String? sku,
    String? barcode,
    String? cost,
    Object? categoryId = _unset,
    Object? categoryName = _unset,
    Object? imagePath = _unset,
    Object? imageThumbnailPath = _unset,
    bool? trackStock,
    bool? isActive,
    bool? isRecommended,
    String? description,
    String? brand,
    String? unit,
    String? supplier,
    List<ProductOptionGroup>? optionGroups,
  }) {
    return ProductDraft(
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      cost: cost ?? this.cost,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      categoryName: identical(categoryName, _unset)
          ? this.categoryName
          : categoryName as String?,
      imagePath: identical(imagePath, _unset)
          ? this.imagePath
          : imagePath as String?,
      imageThumbnailPath: identical(imageThumbnailPath, _unset)
          ? this.imageThumbnailPath
          : imageThumbnailPath as String?,
      trackStock: trackStock ?? this.trackStock,
      isActive: isActive ?? this.isActive,
      isRecommended: isRecommended ?? this.isRecommended,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      unit: unit ?? this.unit,
      supplier: supplier ?? this.supplier,
      optionGroups: optionGroups ?? this.optionGroups,
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
    isRecommended,
    description,
    brand,
    unit,
    supplier,
    optionGroups,
  ];
}
