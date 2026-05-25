import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

class UpdateProduct {
  const UpdateProduct(this._repository);
  final ProductRepository _repository;

  Future<void> call(Product product) => _repository.updateProduct(product);
}
