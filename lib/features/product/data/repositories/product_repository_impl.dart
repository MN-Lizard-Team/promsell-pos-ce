import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
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
  Future<List<Product>> getAllProducts() => _datasource.getAllProducts();

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
    return _datasource.barcodeExistsAnyStatus(
      barcode.toUpperCase(),
      excludeId: excludeId,
    );
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
    bool isActive = true,
    String? description,
    String? brand,
    String? unit,
    String? supplier,
    bool isRecommended = false,
    List<ProductOptionGroup> optionGroups = const [],
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
      // Check barcode uniqueness before generating image
      final exists = await _datasource.barcodeExistsAnyStatus(
        normalizedBarcode,
      );
      if (exists) {
        throw Exception('Barcode already exists: $normalizedBarcode');
      }

      barcodeImagePath = await _barcodeImageService.generate(
        barcode: normalizedBarcode,
        productId: id,
      );
    }

    try {
      final companion = ProductsCompanion.insert(
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
        isActive: Value(isActive),
        description: Value(description),
        brand: Value(brand),
        unit: Value(unit),
        supplier: Value(supplier),
        isRecommended: Value(isRecommended),
        createdAt: Value(now),
        updatedAt: Value(now),
      );
      if (optionGroups.isEmpty) {
        await _datasource.insertProduct(companion);
      } else {
        await _datasource.insertProductWithOptionGroups(
          companion,
          optionGroups,
        );
      }
      return id;
    } catch (e) {
      if (finalImagePath != null) {
        await _imageService.deleteImages(finalImagePath, finalThumbPath);
      }
      if (barcodeImagePath != null) {
        await _barcodeImageService.delete(id);
      }
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(
    Product product, {
    List<ProductOptionGroup>? optionGroups,
  }) async {
    final existing = await _datasource.getProductById(product.id);

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

    String? oldImagePath;
    String? oldThumbPath;
    bool imageChanged = false;
    bool imageRemoved = false;
    if (existing != null) {
      oldImagePath = existing.imagePath;
      oldThumbPath = existing.imageThumbnailPath;
      imageChanged =
          oldImagePath != finalImagePath || oldThumbPath != finalThumbPath;
      imageRemoved =
          (oldImagePath != null || oldThumbPath != null) &&
          (finalImagePath == null && finalThumbPath == null);
    }

    String? barcodeImagePath;
    final normalizedBarcode = product.barcode?.toUpperCase().trim();
    if (normalizedBarcode != null && normalizedBarcode.isNotEmpty) {
      final existingBarcode = existing?.barcode?.toUpperCase().trim();
      if (existingBarcode == normalizedBarcode &&
          existing?.barcodeImagePath != null) {
        barcodeImagePath = existing!.barcodeImagePath;
      } else {
        // Check barcode uniqueness (excluding current product)
        final exists = await _datasource.barcodeExistsAnyStatus(
          normalizedBarcode,
          excludeId: product.id,
        );
        if (exists) {
          throw Exception('Barcode already exists: $normalizedBarcode');
        }

        if (existing?.barcodeImagePath != null) {
          await _barcodeImageService.delete(product.id);
        }
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
    final companion = ProductsCompanion(
      id: Value(product.id),
      name: Value(product.name),
      sku: Value(product.sku),
      barcode: Value(normalizedBarcode),
      price: Value(product.price.value),
      cost: Value(product.cost.value),
      stock: Value(product.stock),
      categoryId: Value(product.categoryId),
      imageUrl: Value(product.imageUrl),
      imagePath: Value(finalImagePath),
      imageThumbnailPath: Value(finalThumbPath),
      barcodeImagePath: Value(barcodeImagePath),
      isActive: Value(product.isActive),
      trackStock: Value(product.trackStock),
      description: Value(product.description),
      brand: Value(product.brand),
      unit: Value(product.unit),
      supplier: Value(product.supplier),
      isRecommended: Value(product.isRecommended),
      updatedAt: Value(now),
    );
    if (optionGroups == null) {
      await _datasource.updateProduct(companion);
    } else {
      await _datasource.updateProductWithOptionGroups(companion, optionGroups);
    }

    if (imageChanged || imageRemoved) {
      await _imageService.deleteImages(oldImagePath, oldThumbPath);
    }
  }

  @override
  Future<void> bulkUpdateBarcodes(
    List<({String id, String barcode})> updates,
  ) async {
    final updatesWithImages =
        <({String id, String barcode, String? barcodeImagePath})>[];
    for (final u in updates) {
      final normalizedBarcode = u.barcode.toUpperCase();
      final barcodeImagePath = await _barcodeImageService.generate(
        barcode: normalizedBarcode,
        productId: u.id,
      );
      updatesWithImages.add((
        id: u.id,
        barcode: normalizedBarcode,
        barcodeImagePath: barcodeImagePath,
      ));
    }
    await _datasource.bulkUpdateBarcodesWithImages(updatesWithImages);
  }

  @override
  Future<void> deleteProduct(String id) async {
    // Check for references in sale_items and draft_cart_items
    final saleItemsCount = await _datasource.countSaleItemsByProduct(id);
    if (saleItemsCount > 0) {
      throw Exception(
        'Cannot delete product: $saleItemsCount sale(s) reference this product',
      );
    }

    final draftItemsCount = await _datasource.countDraftItemsByProduct(id);
    if (draftItemsCount > 0) {
      throw Exception(
        'Cannot delete product: $draftItemsCount draft cart(s) reference this product',
      );
    }

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
