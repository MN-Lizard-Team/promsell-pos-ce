import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';

void main() {
  group('Ean13Generator', () {
    test('generates 13-digit barcode', () {
      final barcode = Ean13Generator.generate();
      expect(barcode.length, 13);
      expect(RegExp(r'^[0-9]{13}$').hasMatch(barcode), isTrue);
    });

    test('generates barcode with default prefix 200', () {
      final barcode = Ean13Generator.generate();
      expect(barcode.startsWith('200'), isTrue);
    });

    test('generates barcode with custom prefix', () {
      final barcode = Ean13Generator.generate(prefix: '690');
      expect(barcode.startsWith('690'), isTrue);
    });

    test('falls back to default when prefix is empty', () {
      final barcode = Ean13Generator.generate(prefix: '');
      expect(barcode.startsWith('200'), isTrue);
    });

    test('falls back to default when prefix is null', () {
      final barcode = Ean13Generator.generate(prefix: null);
      expect(barcode.startsWith('200'), isTrue);
    });

    test('check digit is valid EAN-13 Luhn', () {
      for (var i = 0; i < 10; i++) {
        final barcode = Ean13Generator.generate();
        final twelve = barcode.substring(0, 12);
        final checkDigit = int.parse(barcode[12]);

        var sum = 0;
        for (var j = 0; j < 12; j++) {
          final d = int.parse(twelve[j]);
          sum += (j % 2 == 0) ? d : d * 3;
        }
        final expected = (10 - (sum % 10)) % 10;
        expect(
          checkDigit,
          equals(expected),
          reason: 'Check digit mismatch for barcode $barcode',
        );
      }
    });

    test('generates unique barcodes in rapid succession', () {
      final barcodes = <String>{};
      for (var i = 0; i < 100; i++) {
        barcodes.add(Ean13Generator.generate());
      }
      expect(barcodes.length, 100);
    });

    test('prefix 1 digit is padded to 3 digits', () {
      final barcode = Ean13Generator.generate(prefix: '2');
      expect(barcode.length, 13);
      expect(barcode.startsWith('002'), isTrue);
    });

    test('prefix 2 digits is padded to 3 digits', () {
      final barcode = Ean13Generator.generate(prefix: '69');
      expect(barcode.length, 13);
      expect(barcode.startsWith('069'), isTrue);
    });

    test('prefix 3 digits is not padded', () {
      final barcode = Ean13Generator.generate(prefix: '200');
      expect(barcode.length, 13);
      expect(barcode.startsWith('200'), isTrue);
    });

    test('initCounter sets the internal counter', () {
      Ean13Generator.initCounter(42);
      expect(Ean13Generator.currentCounter, 42);
    });

    test('initCounter wraps around at 100000', () {
      Ean13Generator.initCounter(100001);
      expect(Ean13Generator.currentCounter, 1);
    });

    test('counter increments after generate', () {
      Ean13Generator.initCounter(0);
      Ean13Generator.generate();
      expect(Ean13Generator.currentCounter, 1);
    });
  });
}
