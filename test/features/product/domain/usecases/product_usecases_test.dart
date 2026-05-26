import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
      when(() => mockRepo.addProduct(
            name: any(named: 'name'),
            price: any(named: 'price'),
            stock: any(named: 'stock'),
            category: any(named: 'category'),
            imageUrl: any(named: 'imageUrl'),
          )).thenAnswer((_) async => 1);

      final result = await useCase(
        name: 'Test',
        price: 100.0,
        stock: 10,
      );

      expect(result, 1);
      verify(() => mockRepo.addProduct(
            name: 'Test',
            price: 100.0,
            stock: 10,
          )).called(1);
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
  });

  group('DeleteProduct', () {
    late DeleteProduct useCase;
    setUp(() => useCase = DeleteProduct(mockRepo));

    test('delegates to repository.deleteProduct', () async {
      when(() => mockRepo.deleteProduct(any())).thenAnswer((_) async {});

      await useCase(1);

      verify(() => mockRepo.deleteProduct(1)).called(1);
    });
  });

  group('GetProducts', () {
    late GetProducts useCase;
    setUp(() => useCase = GetProducts(mockRepo));

    test('delegates to repository.watchAllProducts', () {
      when(() => mockRepo.watchAllProducts())
          .thenAnswer((_) => Stream.value([tProduct, tProduct2]));

      final stream = useCase();

      expect(stream, emits([tProduct, tProduct2]));
      verify(() => mockRepo.watchAllProducts()).called(1);
    });
  });
}
