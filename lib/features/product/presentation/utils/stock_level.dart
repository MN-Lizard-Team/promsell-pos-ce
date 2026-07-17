import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

/// Shared low-stock rules for list filters, stats, tiles, and preview.
///
/// Prefer [settings.lowStockThreshold] over hardcoding 5.
bool isProductLowStock(Product product, {required int lowStockThreshold}) {
  if (!product.trackStock) return false;
  final threshold = lowStockThreshold < 1 ? 1 : lowStockThreshold;
  return product.stock > 0 && product.stock <= threshold;
}

bool isStockQtyLow(
  int stock, {
  required int lowStockThreshold,
  bool trackStock = true,
}) {
  if (!trackStock) return false;
  final threshold = lowStockThreshold < 1 ? 1 : lowStockThreshold;
  return stock > 0 && stock <= threshold;
}

bool isProductOutOfStock(Product product) {
  return product.trackStock && product.stock <= 0;
}
