import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';

@injectable
class WatchCategories {
  const WatchCategories(this._repository);
  final CategoryRepository _repository;

  Stream<List<Category>> call() => _repository.watchCategories();
}
