import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class GetProducts {
  const GetProducts(this._repository);
  final ProductRepository _repository;

  Stream<List<Product>> call({int? limit}) =>
      _repository.watchAllProducts(limit: limit);
}

@injectable
class GetProductCount {
  const GetProductCount(this._repository);
  final ProductRepository _repository;

  Future<int> call() => _repository.getProductCount();
}
