import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class AddProduct {
  const AddProduct(this._repository);
  final ProductRepository _repository;

  Future<String> call({
    required String name,
    required double price,
    required int stock,
    String? category,
    String? imageUrl,
    String? imagePath,
    String? imageThumbnailPath,
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
      imagePath: imagePath,
      imageThumbnailPath: imageThumbnailPath,
      trackStock: trackStock,
    );
  }
}
