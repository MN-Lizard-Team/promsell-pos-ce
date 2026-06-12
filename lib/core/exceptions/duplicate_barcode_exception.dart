/// Thrown when a product is saved with a barcode that already exists.
class DuplicateBarcodeException implements Exception {
  const DuplicateBarcodeException(this.barcode);
  final String barcode;

  @override
  String toString() =>
      'Barcode "$barcode" is already assigned to another product.';
}
