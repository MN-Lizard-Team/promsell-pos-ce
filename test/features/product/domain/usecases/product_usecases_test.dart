import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
  });

  setUpAll(() {
    registerFallbackValue(tProduct);
  });

  group('AddProduct', () {
    late AddProduct useCase;
    setUp(() => useCase = AddProduct(mockRepo));

    test('delegates to repository.addProduct and returns id', () async {
      when(
        () => mockRepo.addProduct(
          name: any(named: 'name'),
          price: any(named: 'price'),
          stock: any(named: 'stock'),
          categoryId: any(named: 'categoryId'),
          imageUrl: any(named: 'imageUrl'),
          imagePath: any(named: 'imagePath'),
        ),
      ).thenAnswer((_) async => 'new-uuid');

      final result = await useCase(name: 'Test', price: 100.0, stock: 10);

      expect(result, 'new-uuid');
      verify(
        () => mockRepo.addProduct(name: 'Test', price: 100.0, stock: 10),
      ).called(1);
    });

    test('throws DuplicateBarcodeException when barcode exists', () async {
      when(() => mockRepo.barcodeExists('dup')).thenAnswer((_) async => true);

      expect(
        () => useCase(name: 'Test', price: 100.0, stock: 10, barcode: 'dup'),
        throwsA(isA<DuplicateBarcodeException>()),
      );
      verify(() => mockRepo.barcodeExists('dup')).called(1);
      verifyNever(
        () => mockRepo.addProduct(
          name: any(named: 'name'),
          price: any(named: 'price'),
          stock: any(named: 'stock'),
        ),
      );
    });
  });

  group('UpdateProduct', () {
    late UpdateProduct useCase;
    setUp(() => useCase = UpdateProduct(mockRepo));

    test('delegates to repository.updateProduct', () async {
      when(() => mockRepo.updateProduct(any())).thenAnswer((_) async {});

      await useCase(tProduct);

      verify(() => mockRepo.updateProduct(tProduct)).called(1);
    });

    test(
      'throws DuplicateBarcodeException when barcode exists on another product',
      () async {
        when(
          () =>
              mockRepo.barcodeExists('dup', excludeId: tProductWithBarcode.id),
        ).thenAnswer((_) async => true);

        expect(
          () => useCase(tProductWithBarcode.copyWith(barcode: 'dup')),
          throwsA(isA<DuplicateBarcodeException>()),
        );
        verify(
          () =>
              mockRepo.barcodeExists('dup', excludeId: tProductWithBarcode.id),
        ).called(1);
        verifyNever(() => mockRepo.updateProduct(any()));
      },
    );
  });

  group('DeleteProduct', () {
    late DeleteProduct useCase;
    setUp(() => useCase = DeleteProduct(mockRepo));

    test('delegates to repository.deleteProduct', () async {
      when(() => mockRepo.deleteProduct(any())).thenAnswer((_) async {});

      await useCase('prod-0001-0001-0001-000000000001');

      verify(
        () => mockRepo.deleteProduct('prod-0001-0001-0001-000000000001'),
      ).called(1);
    });
  });

  group('GetProducts', () {
    late GetProducts useCase;
    setUp(() => useCase = GetProducts(mockRepo));

    test('delegates to repository.watchAllProducts', () {
      when(
        () => mockRepo.watchAllProducts(),
      ).thenAnswer((_) => Stream.value([tProduct, tProduct2]));

      final stream = useCase();

      expect(stream, emits([tProduct, tProduct2]));
      verify(() => mockRepo.watchAllProducts()).called(1);
    });
  });
}
