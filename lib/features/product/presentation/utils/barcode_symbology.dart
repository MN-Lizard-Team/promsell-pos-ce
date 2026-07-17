import 'package:barcode_widget/barcode_widget.dart';

/// Shared symbology resolution for form live strip and preview image widget.
Barcode resolveBarcodeSymbology(String raw) {
  final clean = raw.replaceAll(RegExp(r'\s'), '');
  if (RegExp(r'^\d{13}$').hasMatch(clean)) return Barcode.ean13();
  if (RegExp(r'^\d{8}$').hasMatch(clean)) return Barcode.ean8();
  if (RegExp(r'^\d{12}$').hasMatch(clean)) return Barcode.upcA();
  return Barcode.code128();
}

/// Human-readable label for chips / a11y.
String barcodeSymbologyLabel(String raw) {
  final clean = raw.replaceAll(RegExp(r'\s'), '');
  if (RegExp(r'^\d{13}$').hasMatch(clean)) return 'EAN-13';
  if (RegExp(r'^\d{8}$').hasMatch(clean)) return 'EAN-8';
  if (RegExp(r'^\d{12}$').hasMatch(clean)) return 'UPC-A';
  return 'Code 128';
}
