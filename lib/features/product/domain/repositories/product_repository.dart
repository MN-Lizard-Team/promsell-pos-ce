import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAllProducts();
  Future<List<Product>> getActiveProducts();
  Future<Product?> getProductById(String id);
  Future<String> addProduct({
    required String name,
    required double price,
    required int stock,
    String? category,
    String? imageUrl,
    String? imagePath,
    bool trackStock = true,
  });
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
