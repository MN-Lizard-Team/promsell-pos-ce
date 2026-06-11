import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/exceptions/category_exceptions.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';

@injectable
class AddCategory {
  const AddCategory(this._repository);
  final CategoryRepository _repository;

  Future<void> call({
    required String name,
    int sortOrder = 0,
    String? color,
    String? iconName,
  }) async {
    final categories = await _repository.watchCategories().first;
    final lowerName = name.trim().toLowerCase();
    if (categories.any((c) => c.name.toLowerCase() == lowerName)) {
      throw const CategoryNameExistsException();
    }
    return _repository.addCategory(
      name: name.trim(),
      sortOrder: sortOrder,
      color: color,
      iconName: iconName,
    );
  }
}
