import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/exceptions/category_exceptions.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';

@injectable
class AddCategory {
  const AddCategory(this._repository);
  final CategoryRepository _repository;

  /// [sortOrder] `0` means auto-append (`max(existing)+1`), matching CSV import.
  /// Returns the new category id.
  Future<String> call({
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
    final nextSortOrder = sortOrder != 0
        ? sortOrder
        : categories.fold<int>(
                0,
                (highest, c) => c.sortOrder > highest ? c.sortOrder : highest,
              ) +
              1;
    return _repository.addCategory(
      name: name.trim(),
      sortOrder: nextSortOrder,
      color: color,
      iconName: iconName,
    );
  }
}
