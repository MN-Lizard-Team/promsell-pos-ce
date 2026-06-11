import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAllProducts();
  Future<List<Product>> getActiveProducts();
  Future<Product?> getProductById(String id);
  Future<String> addProduct({
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
  });
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
