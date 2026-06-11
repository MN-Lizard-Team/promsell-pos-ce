import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();
  Future<void> addCategory({
    required String name,
    int sortOrder = 0,
    String? color,
    String? iconName,
  });
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
