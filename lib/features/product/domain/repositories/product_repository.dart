import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAllProducts();
  Future<List<Product>> getActiveProducts();
  Future<Product?> getProductById(int id);
  Future<int> addProduct({
    required String name,
    required double price,
    required int stock,
    String? category,
    String? imageUrl,
  });
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}
