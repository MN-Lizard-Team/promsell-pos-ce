import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class UpdateProduct {
  const UpdateProduct(this._repository);
  final ProductRepository _repository;

  Future<void> call(Product product) {
    Validators.productName(product.name);
    Validators.price(product.price);
    Validators.stock(product.stock);
    if (product.category != null && product.category!.isNotEmpty) {
      Validators.productName(product.category!);
    }
    return _repository.updateProduct(product);
  }
}
