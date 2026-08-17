import 'dart:developer' as dev;

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/services/barcode_image_service.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_page.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._datasource, this._imageService);
  final ProductLocalDatasource _datasource;
  final ProductImageService _imageService;
  static final _barcodeImageService = BarcodeImageService();

  @override
  Stream<List<Product>> watchAllProducts({int? limit}) =>
      _datasource.watchAllProducts(limit: limit);

  @override
  Future<ProductPage> getProductsPage({
    ProductCursor? cursor,
    int pageSize = 50,
    bool activeOnly = false,
  }) => _datasource.getProductsPage(
    cursor: cursor,
    pageSize: pageSize,
    activeOnly: activeOnly,
  );

  @override
  Future<ProductPage> searchProductsPage({
    required String query,
    ProductCursor? cursor,
    int pageSize = 50,
    bool activeOnly = false,
  }) => _datasource.searchProductsPage(
    query: query,
    cursor: cursor,
    pageSize: pageSize,
    activeOnly: activeOnly,
  );

  @override
  Future<List<Product>> getActiveProducts() => _datasource.getActiveProducts();

  @override
  Future<List<Product>> getAllProducts() => _datasource.getAllProducts();

  @override
  Future<int> getProductCount() => _datasource.getProductCount();

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
  Future<Product?> getProductBySku(String sku) async {
    final product = await _datasource.getProductBySku(sku.toUpperCase());
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
  Future<bool> skuExists(String sku, {String? excludeId}) async {
    return _datasource.skuExistsAnyStatus(sku, excludeId: excludeId);
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
    // Apply same normalization as Validators.barcode (strip separators, uppercase).
    final cleanedBarcode = barcode == null || barcode.trim().isEmpty
        ? null
        : barcode.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
    final normalizedBarcode = cleanedBarcode;
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
        skuLower: Value(sku?.toLowerCase()),
        barcode: Value(normalizedBarcode),
        barcodeLower: Value(normalizedBarcode?.toLowerCase()),
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
        // Phase M (C2): dual-write satang.
        priceSatang: Value(Money.fromDouble(price)),
        costSatang: Value(cost != null ? Money.fromDouble(cost) : null),
      );
      if (optionGroups.isEmpty) {
        await _datasource.insertProduct(companion);
      } else {
        await _datasource.insertProductWithOptionGroups(
          companion,
          optionGroups,
        );
      }
      await _datasource.logProductAudit(
        productId: id,
        action: 'CREATE',
        newValue: name,
      );
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

    // --- Image rename (file system, outside DB transaction) ---
    // If the DB update fails later, we roll back the rename below.
    String? finalImagePath = product.imagePath;
    String? finalThumbPath = product.imageThumbnailPath;
    String? originalImagePathBeforeRename;
    String? renamedImagePath;
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      final imageName = p.basenameWithoutExtension(product.imagePath!);
      if (imageName != product.id) {
        originalImagePathBeforeRename = product.imagePath;
        final renamed = await _imageService.renameImages(
          product.imagePath,
          product.id,
        );
        if (renamed != null) {
          finalImagePath = renamed.fullPath;
          finalThumbPath = renamed.thumbnailPath;
          renamedImagePath = renamed.fullPath;
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
    // Apply same normalization as Validators.barcode (strip separators, uppercase).
    final normalizedBarcode =
        product.barcode == null || product.barcode!.trim().isEmpty
        ? null
        : product.barcode!.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
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

        // Generate new barcode image BEFORE deleting old one so that
        // a generation failure doesn't leave the product without an image.
        final newBarcodeImage = await _barcodeImageService.generate(
          barcode: normalizedBarcode,
          productId: product.id,
        );
        if (existing?.barcodeImagePath != null) {
          await _barcodeImageService.delete(product.id);
        }
        barcodeImagePath = newBarcodeImage;
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
      skuLower: Value(product.sku?.toLowerCase()),
      barcode: Value(normalizedBarcode),
      barcodeLower: Value(normalizedBarcode?.toLowerCase()),
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
      version: Value(product.version),
      // Phase M (C2): dual-write satang.
      priceSatang: Value(product.price),
      costSatang: Value(product.cost),
    );

    // --- Build audit entries (will be written atomically with the update) ---
    final auditEntries =
        <({String fieldName, String oldValue, String newValue})>[];
    if (existing != null) {
      if (existing.price.value != product.price.value) {
        auditEntries.add((
          fieldName: 'price',
          oldValue: existing.price.value.toStringAsFixed(2),
          newValue: product.price.value.toStringAsFixed(2),
        ));
      }
      if (existing.stock != product.stock) {
        auditEntries.add((
          fieldName: 'stock',
          oldValue: existing.stock.toString(),
          newValue: product.stock.toString(),
        ));
      }
      if (existing.cost.value != product.cost.value) {
        auditEntries.add((
          fieldName: 'cost',
          oldValue: existing.cost.value.toStringAsFixed(2),
          newValue: product.cost.value.toStringAsFixed(2),
        ));
      }
      if (existing.name != product.name) {
        auditEntries.add((
          fieldName: 'name',
          oldValue: existing.name,
          newValue: product.name,
        ));
      }
      if (existing.barcode != normalizedBarcode) {
        auditEntries.add((
          fieldName: 'barcode',
          oldValue: existing.barcode ?? '',
          newValue: normalizedBarcode ?? '',
        ));
      }
      if (existing.sku != product.sku) {
        auditEntries.add((
          fieldName: 'sku',
          oldValue: existing.sku ?? '',
          newValue: product.sku ?? '',
        ));
      }
      if (existing.isActive != product.isActive) {
        auditEntries.add((
          fieldName: 'isActive',
          oldValue: existing.isActive.toString(),
          newValue: product.isActive.toString(),
        ));
      }
    }

    // --- Atomic DB update + audit logging in a single transaction ---
    try {
      await _datasource.updateProductWithAudit(
        companion,
        optionGroups,
        auditEntries,
      );
    } catch (e) {
      // Compensating rollback: if the DB update failed, undo the image rename
      // so we don't leave orphaned files with the product ID name.
      if (renamedImagePath != null && originalImagePathBeforeRename != null) {
        try {
          await _imageService.renameImages(
            renamedImagePath,
            p.basenameWithoutExtension(originalImagePathBeforeRename),
          );
        } catch (rollbackError) {
          dev.log(
            'Image rename rollback failed for product ${product.id}: $rollbackError',
            level: 900,
            name: 'ProductRepository',
          );
        }
      }
      rethrow;
    }

    // --- Best-effort old image cleanup (after successful update) ---
    if (imageChanged || imageRemoved) {
      try {
        await _imageService.deleteImages(oldImagePath, oldThumbPath);
      } catch (e) {
        dev.log(
          'Old image cleanup failed for product ${product.id}: $e',
          level: 900,
          name: 'ProductRepository',
        );
      }
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
    // Soft-delete in DB first so a failure doesn't leave orphaned image paths.
    await _datasource.deleteProduct(id);
    await _datasource.logProductAudit(
      productId: id,
      action: 'DELETE',
      newValue: product?.name,
    );
    if (product != null) {
      // Best-effort image cleanup — failures here don't roll back the soft-delete
      // (orphaned files are a storage concern, not a data-integrity concern).
      try {
        await _imageService.deleteImages(
          product.imagePath,
          product.imageThumbnailPath,
        );
        await _barcodeImageService.delete(id);
      } catch (e) {
        // Log warning but don't fail the delete operation.
        dev.log(
          'Image cleanup failed for deleted product $id: $e',
          level: 900,
          name: 'ProductRepository',
        );
      }
    }
  }

  @override
  Future<void> restoreProduct(String id) async {
    await _datasource.restoreProduct(id);
    await _datasource.logProductAudit(productId: id, action: 'RESTORE');
  }
}
