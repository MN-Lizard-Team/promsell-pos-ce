import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';

@injectable
class ReorderCategories {
  const ReorderCategories(this._repo);
  final CategoryRepository _repo;

  Future<void> call(List<String> orderedIds) =>
      _repo.reorderCategories(orderedIds);
}
