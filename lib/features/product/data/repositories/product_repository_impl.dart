import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._datasource);
  final ProductLocalDatasource _datasource;

  @override
  Stream<List<Product>> watchAllProducts() => _datasource.watchAllProducts();

  @override
  Future<List<Product>> getActiveProducts() => _datasource.getActiveProducts();

  @override
  Future<Product?> getProductById(int id) => _datasource.getProductById(id);

  @override
  Future<int> addProduct({
    required String name,
    required double price,
    required int stock,
    String? category,
    String? imageUrl,
  }) {
    final now = DateTime.now();
    return _datasource.insertProduct(
      ProductsCompanion.insert(
        name: name,
        price: price,
        stock: Value(stock),
        category: Value(category),
        imageUrl: Value(imageUrl),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateProduct(Product product) {
    final now = DateTime.now();
    return _datasource.updateProduct(
      ProductsCompanion(
        id: Value(product.id),
        name: Value(product.name),
        price: Value(product.price),
        stock: Value(product.stock),
        category: Value(product.category),
        imageUrl: Value(product.imageUrl),
        isActive: Value(product.isActive),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteProduct(int id) => _datasource.deleteProduct(id);
}
