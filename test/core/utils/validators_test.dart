import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';

void main() {
  group('Validators.barcode', () {
    test('returns null for null input', () {
      expect(Validators.barcode(null), isNull);
    });

    test('returns null for empty string', () {
      expect(Validators.barcode(''), isNull);
    });

    test('accepts alphanumeric barcode', () {
      expect(Validators.barcode('ABC123'), 'ABC123');
    });

    test('accepts numeric-only barcode', () {
      expect(Validators.barcode('123456789012'), '123456789012');
    });

    test('accepts single character', () {
      expect(Validators.barcode('A'), 'A');
    });

    test('accepts 50-character barcode', () {
      final barcode = 'A' * 50;
      expect(Validators.barcode(barcode), barcode);
    });

    test('throws for 51-character barcode', () {
      final barcode = 'A' * 51;
      expect(() => Validators.barcode(barcode), throwsArgumentError);
    });

    test('throws for barcode with spaces', () {
      expect(() => Validators.barcode('ABC 123'), throwsArgumentError);
    });

    test('throws for barcode with special characters', () {
      expect(() => Validators.barcode('ABC-123'), throwsArgumentError);
    });
  });
}
