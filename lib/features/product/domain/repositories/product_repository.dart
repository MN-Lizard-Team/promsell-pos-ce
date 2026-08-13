import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAllProducts({int? limit});
  Future<List<Product>> getActiveProducts();

  /// Total count of non-deleted products (for UI indicators + pagination).
  Future<int> getProductCount();

  /// All products (active + inactive), for full-catalog ops like batch barcodes.
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<bool> barcodeExists(String barcode, {String? excludeId});

  /// Case-insensitive SKU existence (active + inactive). Empty/null → false.
  Future<bool> skuExists(String sku, {String? excludeId});
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
  });
  Future<void> updateProduct(
    Product product, {
    List<ProductOptionGroup>? optionGroups,
  });
  Future<void> bulkUpdateBarcodes(List<({String id, String barcode})> updates);
  Future<void> deleteProduct(String id);

  /// Restores a soft-deleted product (undo delete).
  Future<void> restoreProduct(String id);
}
