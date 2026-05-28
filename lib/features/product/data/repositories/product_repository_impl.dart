import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
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
  Future<Product?> getProductById(String id) => _datasource.getProductById(id);

  @override
  Future<String> addProduct({
    required String name,
    required double price,
    required int stock,
    String? category,
    String? imageUrl,
    bool trackStock = true,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _datasource.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: name,
        price: price,
        stock: Value(stock),
        categoryId: Value(category),
        imageUrl: Value(imageUrl),
        trackStock: Value(trackStock),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
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
        categoryId: Value(product.category),
        imageUrl: Value(product.imageUrl),
        isActive: Value(product.isActive),
        trackStock: Value(product.trackStock),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteProduct(String id) => _datasource.deleteProduct(id);
}
