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

  group('Validators.productName', () {
    test('trims and returns valid name', () {
      expect(Validators.productName('  Coffee  '), 'Coffee');
    });

    test('throws for empty name', () {
      expect(() => Validators.productName('   '), throwsArgumentError);
    });

    test('throws for too long name', () {
      expect(() => Validators.productName('A' * 201), throwsArgumentError);
    });
  });

  group('Validators.price', () {
    test('accepts positive price', () {
      expect(Validators.price(50), 50.0);
    });

    test('throws for zero price', () {
      expect(() => Validators.price(0), throwsArgumentError);
    });

    test('throws for negative price', () {
      expect(() => Validators.price(-1), throwsArgumentError);
    });

    test('throws for more than 2 decimals', () {
      expect(() => Validators.price(1.234), throwsArgumentError);
    });
  });

  group('Validators.stock', () {
    test('accepts zero stock', () {
      expect(Validators.stock(0), 0);
    });

    test('accepts positive stock', () {
      expect(Validators.stock(10), 10);
    });

    test('throws for negative stock', () {
      expect(() => Validators.stock(-1), throwsArgumentError);
    });
  });

  group('Validators.discountValue', () {
    test('accepts zero discount', () {
      expect(Validators.discountValue(0, type: 'PERCENT'), 0);
    });

    test('accepts percent up to 100', () {
      expect(Validators.discountValue(100, type: 'PERCENT'), 100);
    });

    test('throws for percent over 100', () {
      expect(
        () => Validators.discountValue(101, type: 'PERCENT'),
        throwsArgumentError,
      );
    });

    test('throws for negative discount', () {
      expect(
        () => Validators.discountValue(-1, type: 'AMOUNT'),
        throwsArgumentError,
      );
    });
  });

  group('Validators.qty', () {
    test('accepts positive qty', () {
      expect(Validators.qty(1), 1);
    });

    test('throws for zero qty', () {
      expect(() => Validators.qty(0), throwsArgumentError);
    });
  });

  group('Validators.nonEmptyCart', () {
    test('throws for empty cart', () {
      expect(() => Validators.nonEmptyCart([]), throwsArgumentError);
    });

    test('does not throw for non-empty cart', () {
      expect(() => Validators.nonEmptyCart([1]), returnsNormally);
    });
  });

  group('Validators.promptpayId', () {
    test('returns null for null input', () {
      expect(Validators.promptpayId(null), isNull);
    });

    test('accepts valid mobile number', () {
      expect(Validators.promptpayId('081-234-5678'), '0812345678');
    });

    test('throws for invalid mobile prefix', () {
      expect(() => Validators.promptpayId('0212345678'), throwsArgumentError);
    });

    test('throws for wrong mobile length', () {
      expect(() => Validators.promptpayId('081234567'), throwsArgumentError);
    });
  });
}
