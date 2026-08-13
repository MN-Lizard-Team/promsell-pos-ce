/// Thrown when a product is saved with a SKU that already exists.
class DuplicateSkuException implements Exception {
  const DuplicateSkuException(this.sku);
  final String sku;

  @override
  String toString() => 'SKU "$sku" is already assigned to another product.';
}
