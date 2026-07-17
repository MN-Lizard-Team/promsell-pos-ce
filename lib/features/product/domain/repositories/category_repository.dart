import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();

  /// Inserts a category and returns its id.
  Future<String> addCategory({
    required String name,
    int sortOrder = 0,
    String? color,
    String? iconName,
  });
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> deleteCategories(
    List<String> categoryIds, {
    String? moveProductsToCategoryId,
  });
  Future<void> reorderCategories(List<String> orderedIds);
}
