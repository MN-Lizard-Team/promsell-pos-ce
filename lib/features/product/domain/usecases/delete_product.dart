import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class DeleteProduct {
  const DeleteProduct(this._repository);
  final ProductRepository _repository;

  Future<void> call(String id) => _repository.deleteProduct(id);
}
