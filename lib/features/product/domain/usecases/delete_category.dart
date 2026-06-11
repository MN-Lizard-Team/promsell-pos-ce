import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/exceptions/category_exceptions.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class DeleteCategory {
  const DeleteCategory(this._categoryRepo, this._productRepo);
  final CategoryRepository _categoryRepo;
  final ProductRepository _productRepo;

  Future<void> call(String id) async {
    final products = await _productRepo.watchAllProducts().first;
    if (products.any((p) => p.categoryId == id)) {
      throw const CategoryInUseException();
    }
    return _categoryRepo.deleteCategory(id);
  }
}
