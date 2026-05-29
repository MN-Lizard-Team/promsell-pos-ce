import 'package:equatable/equatable.dart';

const Object _unset = Object();

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.category,
    this.imageUrl,
    this.imagePath,
    required this.isActive,
    this.trackStock = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String? category;
  final String? imageUrl;
  final String? imagePath;
  final bool isActive;
  final bool trackStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInStock => !trackStock || stock > 0;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    Object? category = _unset,
    Object? imageUrl = _unset,
    Object? imagePath = _unset,
    bool? isActive,
    bool? trackStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: identical(category, _unset)
          ? this.category
          : category as String?,
      imageUrl: identical(imageUrl, _unset)
          ? this.imageUrl
          : imageUrl as String?,
      imagePath: identical(imagePath, _unset)
          ? this.imagePath
          : imagePath as String?,
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
    price,
    stock,
    category,
    imageUrl,
    imagePath,
    isActive,
    trackStock,
    createdAt,
    updatedAt,
  ];
}
