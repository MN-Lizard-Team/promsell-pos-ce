import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';

@injectable
class DeleteCategories {
  const DeleteCategories(this._repository);

  final CategoryRepository _repository;

  Future<void> call(
    List<String> categoryIds, {
    String? moveProductsToCategoryId,
  }) async {
    final ids = categoryIds.toSet().toList();
    if (ids.isEmpty) return;
    if (moveProductsToCategoryId != null &&
        ids.contains(moveProductsToCategoryId)) {
      throw ArgumentError('The destination category cannot be deleted.');
    }
    await _repository.deleteCategories(
      ids,
      moveProductsToCategoryId: moveProductsToCategoryId,
    );
  }
}
