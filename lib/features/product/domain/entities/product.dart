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
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final double price;
  final int stock;
  final String? category;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInStock => stock > 0;

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    Object? category = _unset,
    Object? imageUrl = _unset,
    bool? isActive,
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
      isActive: isActive ?? this.isActive,
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
    isActive,
    createdAt,
    updatedAt,
  ];
}
