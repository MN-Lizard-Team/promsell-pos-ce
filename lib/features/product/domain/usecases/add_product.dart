import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

class AddProduct {
  const AddProduct(this._repository);
  final ProductRepository _repository;

  Future<String> call({
    required String name,
    required double price,
    required int stock,
    String? category,
    String? imageUrl,
    bool trackStock = true,
  }) {
    Validators.productName(name);
    Validators.price(price);
    Validators.stock(stock);
    if (category != null && category.isNotEmpty) {
      Validators.productName(category);
    }
    return _repository.addProduct(
      name: name.trim(),
      price: price,
      stock: stock,
      category: category,
      imageUrl: imageUrl,
      trackStock: trackStock,
    );
  }
}
