import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

class GetProducts {
  const GetProducts(this._repository);
  final ProductRepository _repository;

  Stream<List<Product>> call() => _repository.watchAllProducts();
}
