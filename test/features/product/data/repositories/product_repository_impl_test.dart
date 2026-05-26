import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/repositories/product_repository_impl.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late ProductRepositoryImpl repo;
  late MockProductLocalDatasource mockDs;

  setUp(() {
    mockDs = MockProductLocalDatasource();
    repo = ProductRepositoryImpl(mockDs);
  });

  setUpAll(() {
    registerFallbackValue(ProductsCompanion.insert(
      name: '',
      price: 0,
    ));
  });

  group('ProductRepositoryImpl', () {
    test('watchAllProducts delegates to datasource', () {
      when(() => mockDs.watchAllProducts())
          .thenAnswer((_) => Stream.value([tProduct]));

      expect(repo.watchAllProducts(), emits([tProduct]));
    });

    test('getActiveProducts delegates to datasource', () async {
      when(() => mockDs.getActiveProducts())
          .thenAnswer((_) async => [tProduct]);

      expect(await repo.getActiveProducts(), [tProduct]);
    });

    test('getProductById delegates to datasource', () async {
      when(() => mockDs.getProductById(any()))
          .thenAnswer((_) async => tProduct);

      expect(await repo.getProductById(1), tProduct);
    });

    test('addProduct builds companion and delegates', () async {
      when(() => mockDs.insertProduct(any()))
          .thenAnswer((_) async => 1);

      final result = await repo.addProduct(
        name: 'Test',
        price: 100.0,
        stock: 10,
        category: 'Drinks',
      );

      expect(result, 1);
      final captured =
          verify(() => mockDs.insertProduct(captureAny())).captured.single
              as ProductsCompanion;
      expect(captured.name.value, 'Test');
      expect(captured.price.value, 100.0);
      expect(captured.stock.value, 10);
      expect(captured.category.value, 'Drinks');
    });

    test('updateProduct builds companion and delegates', () async {
      when(() => mockDs.updateProduct(any()))
          .thenAnswer((_) async {});

      await repo.updateProduct(tProduct);

      final captured =
          verify(() => mockDs.updateProduct(captureAny())).captured.single
              as ProductsCompanion;
      expect(captured.id.value, tProduct.id);
      expect(captured.name.value, tProduct.name);
      expect(captured.price.value, tProduct.price);
    });

    test('deleteProduct delegates to datasource', () async {
      when(() => mockDs.deleteProduct(any()))
          .thenAnswer((_) async {});

      await repo.deleteProduct(1);

      verify(() => mockDs.deleteProduct(1)).called(1);
    });
  });
}
