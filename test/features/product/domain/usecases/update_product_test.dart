import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';

import '../../../../helpers/fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepo;
  late UpdateProduct usecase;

  setUpAll(() {
    registerFallbackValue(tProduct);
  });

  setUp(() {
    mockRepo = MockProductRepository();
    usecase = UpdateProduct(mockRepo);
  });

  final validProduct = tProduct.copyWith(
    name: 'Updated Product',
    price: 150.0,
    stock: 30,
  );

  group('UpdateProduct', () {
    test('calls repository.updateProduct for valid product', () async {
      when(() => mockRepo.updateProduct(any())).thenAnswer((_) async {});
      when(
        () => mockRepo.barcodeExists(any(), excludeId: any(named: 'excludeId')),
      ).thenAnswer((_) async => false);

      await usecase(validProduct);

      verify(() => mockRepo.updateProduct(validProduct)).called(1);
    });

    test('throws ArgumentError when name is empty', () async {
      final product = validProduct.copyWith(name: '');

      expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      verifyNever(() => mockRepo.updateProduct(any()));
    });

    test('throws ArgumentError when price is zero', () async {
      final product = validProduct.copyWith(price: 0.0);

      expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      verifyNever(() => mockRepo.updateProduct(any()));
    });

    test('throws ArgumentError when price is negative', () async {
      final product = validProduct.copyWith(price: -10.0);

      expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      verifyNever(() => mockRepo.updateProduct(any()));
    });

    test('throws ArgumentError when stock is negative', () async {
      final product = validProduct.copyWith(stock: -5);

      expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      verifyNever(() => mockRepo.updateProduct(any()));
    });

    test('throws ArgumentError when barcode has special characters', () async {
      final product = validProduct.copyWith(barcode: 'ABC!@#');

      expect(() => usecase(product), throwsA(isA<ArgumentError>()));
      verifyNever(() => mockRepo.updateProduct(any()));
    });

    test(
      'throws DuplicateBarcodeException when barcode exists on another product',
      () async {
        final product = validProduct.copyWith(barcode: '1234567890');
        when(
          () => mockRepo.barcodeExists('1234567890', excludeId: product.id),
        ).thenAnswer((_) async => true);

        expect(
          () => usecase(product),
          throwsA(isA<DuplicateBarcodeException>()),
        );
        verifyNever(() => mockRepo.updateProduct(any()));
      },
    );

    test(
      'does not throw when barcode belongs to same product (excludeId)',
      () async {
        final product = validProduct.copyWith(barcode: '1234567890');
        when(
          () => mockRepo.barcodeExists('1234567890', excludeId: product.id),
        ).thenAnswer((_) async => false);
        when(() => mockRepo.updateProduct(any())).thenAnswer((_) async {});

        await usecase(product);

        verify(() => mockRepo.updateProduct(product)).called(1);
      },
    );

    test('skips barcode check when barcode is null', () async {
      final product = validProduct.copyWith(barcode: null);
      when(() => mockRepo.updateProduct(any())).thenAnswer((_) async {});

      await usecase(product);

      verifyNever(
        () => mockRepo.barcodeExists(any(), excludeId: any(named: 'excludeId')),
      );
      verify(() => mockRepo.updateProduct(product)).called(1);
    });

    test('skips barcode check when barcode is empty', () async {
      final product = validProduct.copyWith(barcode: '');
      when(() => mockRepo.updateProduct(any())).thenAnswer((_) async {});

      await usecase(product);

      verifyNever(
        () => mockRepo.barcodeExists(any(), excludeId: any(named: 'excludeId')),
      );
      verify(() => mockRepo.updateProduct(product)).called(1);
    });
  });
}
