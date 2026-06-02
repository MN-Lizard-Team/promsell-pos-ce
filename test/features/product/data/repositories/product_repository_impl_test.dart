import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/repositories/product_repository_impl.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late ProductRepositoryImpl repo;
  late MockProductLocalDatasource mockDs;
  late MockProductImageService mockImageService;

  setUp(() {
    mockDs = MockProductLocalDatasource();
    mockImageService = MockProductImageService();
    repo = ProductRepositoryImpl(mockDs, mockImageService);
  });

  setUpAll(() {
    registerFallbackValue(
      ProductsCompanion.insert(id: 'fallback', name: '', price: 0),
    );
  });

  group('ProductRepositoryImpl', () {
    test('watchAllProducts delegates to datasource', () {
      when(
        () => mockDs.watchAllProducts(),
      ).thenAnswer((_) => Stream.value([tProduct]));

      expect(repo.watchAllProducts(), emits([tProduct]));
    });

    test('getActiveProducts delegates to datasource', () async {
      when(
        () => mockDs.getActiveProducts(),
      ).thenAnswer((_) async => [tProduct]);

      expect(await repo.getActiveProducts(), [tProduct]);
    });

    test('getProductById delegates to datasource', () async {
      when(
        () => mockDs.getProductById(any()),
      ).thenAnswer((_) async => tProduct);

      expect(
        await repo.getProductById('prod-0001-0001-0001-000000000001'),
        tProduct,
      );
    });

    test('addProduct builds companion and delegates', () async {
      when(() => mockDs.insertProduct(any())).thenAnswer((_) async {});

      final result = await repo.addProduct(
        name: 'Test',
        price: 100.0,
        stock: 10,
        category: 'Drinks',
      );

      expect(result, isA<String>());
      final captured =
          verify(() => mockDs.insertProduct(captureAny())).captured.single
              as ProductsCompanion;
      expect(captured.name.value, 'Test');
      expect(captured.price.value, 100.0);
      expect(captured.stock.value, 10);
      expect(captured.categoryId.value, 'Drinks');
    });

    test('updateProduct builds companion and delegates', () async {
      when(() => mockDs.updateProduct(any())).thenAnswer((_) async {});

      await repo.updateProduct(tProduct);

      final captured =
          verify(() => mockDs.updateProduct(captureAny())).captured.single
              as ProductsCompanion;
      expect(captured.id.value, tProduct.id);
      expect(captured.name.value, tProduct.name);
      expect(captured.price.value, tProduct.price);
    });

    test('deleteProduct deletes images then delegates', () async {
      when(
        () => mockDs.getProductById(any()),
      ).thenAnswer((_) async => tProduct);
      when(
        () => mockImageService.deleteImages(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockDs.deleteProduct(any())).thenAnswer((_) async {});

      await repo.deleteProduct('prod-0001-0001-0001-000000000001');

      verify(() => mockImageService.deleteImages(any(), any())).called(1);
      verify(
        () => mockDs.deleteProduct('prod-0001-0001-0001-000000000001'),
      ).called(1);
    });
  });
}
