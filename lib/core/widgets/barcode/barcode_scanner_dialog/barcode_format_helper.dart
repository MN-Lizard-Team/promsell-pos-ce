import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

BarcodeFormat formatFromName(String name) {
  switch (name) {
    case 'ean13':
      return BarcodeFormat.ean13;
    case 'ean8':
      return BarcodeFormat.ean8;
    case 'upcA':
      return BarcodeFormat.upcA;
    case 'upcE':
      return BarcodeFormat.upcE;
    case 'code128':
      return BarcodeFormat.code128;
    case 'code39':
      return BarcodeFormat.code39;
    case 'itf':
      return BarcodeFormat.itf14;
    case 'qrCode':
      return BarcodeFormat.qrCode;
    case 'dataMatrix':
      return BarcodeFormat.dataMatrix;
    case 'pdf417':
      return BarcodeFormat.pdf417;
    case 'aztec':
      return BarcodeFormat.aztec;
    case 'codabar':
      return BarcodeFormat.codabar;
    default:
      debugPrint('Unknown barcode format "$name", defaulting to ean13');
      return BarcodeFormat.ean13;
  }
}

List<BarcodeFormat> barcodeFormatsFromNames(List<String> names) {
  return names.map(formatFromName).toList();
}
