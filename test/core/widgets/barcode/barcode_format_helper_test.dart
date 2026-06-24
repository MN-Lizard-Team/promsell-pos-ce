import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_format_helper.dart';

void main() {
  group('formatFromName', () {
    test('returns ean13 for ean13', () {
      expect(formatFromName('ean13'), BarcodeFormat.ean13);
    });

    test('returns qrCode for qrCode', () {
      expect(formatFromName('qrCode'), BarcodeFormat.qrCode);
    });

    test('returns code128 for code128', () {
      expect(formatFromName('code128'), BarcodeFormat.code128);
    });

    test('returns ean13 for unknown format', () {
      expect(formatFromName('unknown'), BarcodeFormat.ean13);
    });

    test('returns dataMatrix for dataMatrix', () {
      expect(formatFromName('dataMatrix'), BarcodeFormat.dataMatrix);
    });

    test('returns aztec for aztec', () {
      expect(formatFromName('aztec'), BarcodeFormat.aztec);
    });

    test('returns codabar for codabar', () {
      expect(formatFromName('codabar'), BarcodeFormat.codabar);
    });
  });

  group('barcodeFormatsFromNames', () {
    test('converts list of names to formats', () {
      final formats = barcodeFormatsFromNames(['ean13', 'qrCode', 'code128']);
      expect(formats, [
        BarcodeFormat.ean13,
        BarcodeFormat.qrCode,
        BarcodeFormat.code128,
      ]);
    });

    test('handles empty list', () {
      expect(barcodeFormatsFromNames([]), isEmpty);
    });

    test('defaults unknown to ean13', () {
      final formats = barcodeFormatsFromNames(['unknown']);
      expect(formats, [BarcodeFormat.ean13]);
    });
  });
}
