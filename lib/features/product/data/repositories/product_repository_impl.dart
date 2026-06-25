import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/services/barcode_image_service.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._datasource, this._imageService);
  final ProductLocalDatasource _datasource;
  final ProductImageService _imageService;
  static final _barcodeImageService = BarcodeImageService();

  @override
  Stream<List<Product>> watchAllProducts() => _datasource.watchAllProducts();

  @override
  Future<List<Product>> getActiveProducts() => _datasource.getActiveProducts();

  @override
  Future<Product?> getProductById(String id) => _datasource.getProductById(id);

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final product = await _datasource.getProductByBarcode(
      barcode.toUpperCase(),
    );
    return (product != null && product.isActive) ? product : null;
  }

  @override
  Future<bool> barcodeExists(String barcode, {String? excludeId}) async {
    final product = await _datasource.getProductByBarcode(
      barcode.toUpperCase(),
    );
    if (product == null) return false;
    if (excludeId != null && product.id == excludeId) return false;
    return true;
  }

  @override
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

    String? barcodeImagePath;
    final normalizedBarcode = barcode?.toUpperCase().trim();
    if (normalizedBarcode != null && normalizedBarcode.isNotEmpty) {
      barcodeImagePath = await _barcodeImageService.generate(
        barcode: normalizedBarcode,
        productId: id,
      );
    }

    await _datasource.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: name,
        sku: Value(sku),
        barcode: Value(normalizedBarcode),
        price: price,
        cost: Value(cost),
        stock: Value(stock),
        categoryId: Value(categoryId),
        imageUrl: Value(imageUrl),
        imagePath: Value(finalImagePath),
        imageThumbnailPath: Value(finalThumbPath),
        barcodeImagePath: Value(barcodeImagePath),
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

    // Images picked during edit are saved to a temporary path. Rename them to
    // the final product path before updating the database.
    String? finalImagePath = product.imagePath;
    String? finalThumbPath = product.imageThumbnailPath;
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      final imageName = p.basenameWithoutExtension(product.imagePath!);
      if (imageName != product.id) {
        final renamed = await _imageService.renameImages(
          product.imagePath,
          product.id,
        );
        if (renamed != null) {
          finalImagePath = renamed.fullPath;
          finalThumbPath = renamed.thumbnailPath;
        }
      }
    }

    if (existing != null) {
      final oldPath = existing.imagePath;
      final oldThumb = existing.imageThumbnailPath;
      final newPath = finalImagePath;
      final newThumb = finalThumbPath;

      final imageChanged = oldPath != newPath || oldThumb != newThumb;
      final imageRemoved =
          (oldPath != null || oldThumb != null) &&
          (newPath == null && newThumb == null);

      if (imageChanged || imageRemoved) {
        await _imageService.deleteImages(oldPath, oldThumb);
      }
    }

    String? barcodeImagePath;
    final normalizedBarcode = product.barcode?.toUpperCase().trim();
    if (normalizedBarcode != null && normalizedBarcode.isNotEmpty) {
      final existingBarcode = existing?.barcode?.toUpperCase().trim();
      if (existingBarcode == normalizedBarcode &&
          existing?.barcodeImagePath != null) {
        barcodeImagePath = existing!.barcodeImagePath;
      } else {
        barcodeImagePath = await _barcodeImageService.generate(
          barcode: normalizedBarcode,
          productId: product.id,
        );
      }
    } else if (existing?.barcodeImagePath != null) {
      await _barcodeImageService.delete(product.id);
      barcodeImagePath = null;
    }

    final now = DateTime.now();
    await _datasource.updateProduct(
      ProductsCompanion(
        id: Value(product.id),
        name: Value(product.name),
        sku: Value(product.sku),
        barcode: Value(normalizedBarcode),
        price: Value(product.price),
        cost: Value(product.cost),
        stock: Value(product.stock),
        categoryId: Value(product.categoryId),
        imageUrl: Value(product.imageUrl),
        imagePath: Value(finalImagePath),
        imageThumbnailPath: Value(finalThumbPath),
        barcodeImagePath: Value(barcodeImagePath),
        isActive: Value(product.isActive),
        trackStock: Value(product.trackStock),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> bulkUpdateBarcodes(
    List<({String id, String barcode})> updates,
  ) => _datasource.bulkUpdateBarcodes(updates);

  @override
  Future<void> deleteProduct(String id) async {
    final product = await _datasource.getProductById(id);
    if (product != null) {
      await _imageService.deleteImages(
        product.imagePath,
        product.imageThumbnailPath,
      );
      await _barcodeImageService.delete(id);
    }
    await _datasource.deleteProduct(id);
  }
}
