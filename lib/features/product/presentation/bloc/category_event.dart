import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoryAdded extends CategoryEvent {
  const CategoryAdded({
    required this.name,
    this.sortOrder = 0,
    this.color,
    this.iconName,
  });
  final String name;
  final int sortOrder;
  final String? color;
  final String? iconName;

  @override
  List<Object?> get props => [name, sortOrder, color, iconName];
}

class CategoryUpdated extends CategoryEvent {
  const CategoryUpdated(this.category);
  final Category category;

  @override
  List<Object?> get props => [category];
}

class CategoryDeleted extends CategoryEvent {
  const CategoryDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class CategoriesReordered extends CategoryEvent {
  const CategoriesReordered(this.orderedIds);
  final List<String> orderedIds;

  @override
  List<Object?> get props => [orderedIds];
}
