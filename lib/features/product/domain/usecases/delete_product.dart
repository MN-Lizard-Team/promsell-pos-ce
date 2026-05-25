import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

class DeleteProduct {
  const DeleteProduct(this._repository);
  final ProductRepository _repository;

  Future<void> call(int id) => _repository.deleteProduct(id);
}
