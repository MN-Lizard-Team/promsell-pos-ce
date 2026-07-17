import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

/// True when the product has no usable barcode (null / blank).
bool productNeedsBarcode(Product product) {
  final code = product.barcode;
  return code == null || code.trim().isEmpty;
}

/// Count of products eligible for auto barcode generation.
int countProductsNeedingBarcode(Iterable<Product> products) {
  return products.where(productNeedsBarcode).length;
}
