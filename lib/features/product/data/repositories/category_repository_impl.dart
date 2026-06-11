import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/category_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._datasource);
  final CategoryLocalDatasource _datasource;

  Category _fromData(CategoryData d) => Category(
    id: d.id,
    name: d.name,
    sortOrder: d.sortOrder,
    color: d.color,
    iconName: d.iconName,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  @override
  Stream<List<Category>> watchCategories() =>
      _datasource.watchAll().map((rows) => rows.map(_fromData).toList());

  @override
  Future<void> addCategory({
    required String name,
    int sortOrder = 0,
    String? color,
    String? iconName,
  }) async {
    final now = DateTime.now();
    await _datasource.insert(
      CategoriesCompanion.insert(
        id: IdGenerator.newId(),
        name: name,
        sortOrder: Value(sortOrder),
        color: Value(color),
        iconName: Value(iconName),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateCategory(Category category) async {
    final now = DateTime.now();
    await _datasource.update(
      CategoriesCompanion(
        id: Value(category.id),
        name: Value(category.name),
        sortOrder: Value(category.sortOrder),
        color: Value(category.color),
        iconName: Value(category.iconName),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteCategory(String id) => _datasource.delete(id);
}
