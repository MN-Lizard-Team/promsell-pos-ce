import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

class AddProduct {
  const AddProduct(this._repository);
  final ProductRepository _repository;

  Future<int> call({
    required String name,
    required double price,
    required int stock,
    String? category,
    String? imageUrl,
  }) =>
      _repository.addProduct(
        name: name,
        price: price,
        stock: stock,
        category: category,
        imageUrl: imageUrl,
      );
}
