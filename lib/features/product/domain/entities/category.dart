import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    this.color,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int sortOrder;
  final String? color;
  final String? iconName;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Sentinel for distinguishing "not provided" from "explicitly null".
  static const Object _unset = Object();

  Category copyWith({
    String? id,
    String? name,
    int? sortOrder,
    Object? color = _unset,
    Object? iconName = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      color: identical(color, _unset) ? this.color : color as String?,
      iconName: identical(iconName, _unset)
          ? this.iconName
          : iconName as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    sortOrder,
    color,
    iconName,
    createdAt,
    updatedAt,
  ];
}
