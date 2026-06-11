import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class AddProduct {
  const AddProduct(this._repository);
  final ProductRepository _repository;

  Future<String> call({
    required String name,
    String? sku,
    String? barcode,
    required double price,
    double? cost,
    required int stock,
    String? categoryId,
    String? imageUrl,
    String? imagePath,
    String? imageThumbnailPath,
    bool trackStock = true,
  }) {
    Validators.productName(name);
    Validators.price(price);
    Validators.stock(stock);
    return _repository.addProduct(
      name: name.trim(),
      sku: sku,
      barcode: barcode,
      price: price,
      cost: cost,
      stock: stock,
      categoryId: categoryId,
      imageUrl: imageUrl,
      imagePath: imagePath,
      imageThumbnailPath: imageThumbnailPath,
      trackStock: trackStock,
    );
  }
}
