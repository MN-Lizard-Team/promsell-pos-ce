import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/exceptions/category_exceptions.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';

@injectable
class UpdateCategory {
  const UpdateCategory(this._repository);
  final CategoryRepository _repository;

  Future<void> call(Category category) async {
    final categories = await _repository.watchCategories().first;
    final lowerName = category.name.trim().toLowerCase();
    if (categories.any(
      (c) => c.id != category.id && c.name.toLowerCase() == lowerName,
    )) {
      throw const CategoryNameExistsException();
    }
    return _repository.updateCategory(category);
  }
}
