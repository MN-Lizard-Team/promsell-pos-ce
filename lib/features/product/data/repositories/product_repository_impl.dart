import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._datasource, this._imageService);
  final ProductLocalDatasource _datasource;
  final ProductImageService _imageService;

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
    String? imagePath,
    String? imageThumbnailPath,
    bool trackStock = true,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();

    String? finalImagePath = imagePath;
    String? finalThumbPath = imageThumbnailPath;
    if (imagePath != null && imagePath.isNotEmpty) {
      final renamed = await _imageService.renameImages(imagePath, id);
      if (renamed != null) {
        finalImagePath = renamed.fullPath;
        finalThumbPath = renamed.thumbnailPath;
      }
    }

    await _datasource.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: name,
        price: price,
        stock: Value(stock),
        categoryId: Value(category),
        imageUrl: Value(imageUrl),
        imagePath: Value(finalImagePath),
        imageThumbnailPath: Value(finalThumbPath),
        trackStock: Value(trackStock),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateProduct(Product product) async {
    final existing = await _datasource.getProductById(product.id);
    if (existing != null) {
      final oldPath = existing.imagePath;
      final oldThumb = existing.imageThumbnailPath;
      final newPath = product.imagePath;
      final newThumb = product.imageThumbnailPath;

      final imageChanged = oldPath != newPath || oldThumb != newThumb;
      final imageRemoved =
          (oldPath != null || oldThumb != null) &&
          (newPath == null && newThumb == null);

      if (imageChanged || imageRemoved) {
        await _imageService.deleteImages(oldPath, oldThumb);
      }
    }

    final now = DateTime.now();
    await _datasource.updateProduct(
      ProductsCompanion(
        id: Value(product.id),
        name: Value(product.name),
        price: Value(product.price),
        stock: Value(product.stock),
        categoryId: Value(product.category),
        imageUrl: Value(product.imageUrl),
        imagePath: Value(product.imagePath),
        imageThumbnailPath: Value(product.imageThumbnailPath),
        isActive: Value(product.isActive),
        trackStock: Value(product.trackStock),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    final product = await _datasource.getProductById(id);
    if (product != null) {
      await _imageService.deleteImages(
        product.imagePath,
        product.imageThumbnailPath,
      );
    }
    await _datasource.deleteProduct(id);
  }
}
