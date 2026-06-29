import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/repositories/product_repository_impl.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';

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
        categoryId: 'drinks-001',
      );

      expect(result, isA<String>());
      final captured =
          verify(() => mockDs.insertProduct(captureAny())).captured.single
              as ProductsCompanion;
      expect(captured.name.value, 'Test');
      expect(captured.price.value, 100.0);
      expect(captured.stock.value, 10);
      expect(captured.categoryId.value, 'drinks-001');
    });

    test('updateProduct builds companion and delegates', () async {
      when(
        () => mockDs.getProductById(any()),
      ).thenAnswer((_) async => tProduct);
      when(() => mockDs.updateProduct(any())).thenAnswer((_) async {});

      await repo.updateProduct(tProduct);

      final captured =
          verify(() => mockDs.updateProduct(captureAny())).captured.single
              as ProductsCompanion;
      expect(captured.id.value, tProduct.id);
      expect(captured.name.value, tProduct.name);
      expect(captured.price.value, tProduct.price);
    });

    test('updateProduct deletes old images when imagePath changes', () async {
      final oldProduct = tProduct.copyWith(
        imagePath: '/old/path.jpg',
        imageThumbnailPath: '/old/path_thumb.jpg',
      );
      final updatedProduct = tProduct.copyWith(
        imagePath: '/new/path.jpg',
        imageThumbnailPath: '/new/path_thumb.jpg',
      );
      when(
        () => mockDs.getProductById(any()),
      ).thenAnswer((_) async => oldProduct);
      when(
        () => mockImageService.deleteImages(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockImageService.renameImages(any(), any()),
      ).thenAnswer((_) async => null);
      when(() => mockDs.updateProduct(any())).thenAnswer((_) async {});

      await repo.updateProduct(updatedProduct);

      verify(
        () => mockImageService.deleteImages(
          '/old/path.jpg',
          '/old/path_thumb.jpg',
        ),
      ).called(1);
    });

    test('updateProduct deletes old images when image is removed', () async {
      final oldProduct = tProduct.copyWith(
        imagePath: '/old/path.jpg',
        imageThumbnailPath: '/old/path_thumb.jpg',
      );
      final updatedProduct = tProduct.copyWith(
        imagePath: null,
        imageThumbnailPath: null,
      );
      when(
        () => mockDs.getProductById(any()),
      ).thenAnswer((_) async => oldProduct);
      when(
        () => mockImageService.deleteImages(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockDs.updateProduct(any())).thenAnswer((_) async {});

      await repo.updateProduct(updatedProduct);

      verify(
        () => mockImageService.deleteImages(
          '/old/path.jpg',
          '/old/path_thumb.jpg',
        ),
      ).called(1);
    });

    test('updateProduct does not delete images when paths unchanged', () async {
      final oldProduct = tProduct.copyWith(
        imagePath: '/same/path.jpg',
        imageThumbnailPath: '/same/path_thumb.jpg',
      );
      final updatedProduct = oldProduct.copyWith(name: 'New Name');
      when(
        () => mockDs.getProductById(any()),
      ).thenAnswer((_) async => oldProduct);
      when(
        () => mockImageService.renameImages(any(), any()),
      ).thenAnswer((_) async => null);
      when(() => mockDs.updateProduct(any())).thenAnswer((_) async {});

      await repo.updateProduct(updatedProduct);

      verifyNever(() => mockImageService.deleteImages(any(), any()));
    });

    test(
      'barcodeExists returns true when barcode exists for different product',
      () async {
        when(
          () => mockDs.barcodeExistsAnyStatus(
            any(),
            excludeId: any(named: 'excludeId'),
          ),
        ).thenAnswer((_) async => true);

        expect(await repo.barcodeExists('dup', excludeId: 'other-id'), true);
      },
    );

    test('getProductByBarcode returns active product', () async {
      when(
        () => mockDs.getProductByBarcode('123'),
      ).thenAnswer((_) async => tProductWithBarcode);

      final result = await repo.getProductByBarcode('123');

      expect(result, tProductWithBarcode);
    });

    test('getProductByBarcode normalizes to uppercase', () async {
      when(
        () => mockDs.getProductByBarcode('ABC123'),
      ).thenAnswer((_) async => tProductWithBarcode);

      final result = await repo.getProductByBarcode('abc123');

      expect(result, tProductWithBarcode);
      verify(() => mockDs.getProductByBarcode('ABC123')).called(1);
    });

    test('getProductByBarcode returns null for inactive product', () async {
      when(
        () => mockDs.getProductByBarcode('123'),
      ).thenAnswer((_) async => tInactiveProduct);

      final result = await repo.getProductByBarcode('123');

      expect(result, isNull);
    });

    test('barcodeExists respects excludeId', () async {
      when(
        () => mockDs.barcodeExistsAnyStatus(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);

      expect(
        await repo.barcodeExists(
          'dup',
          excludeId: 'prod-0001-0001-0001-000000000001',
        ),
        false,
      );
      verify(
        () => mockDs.barcodeExistsAnyStatus(
          'DUP',
          excludeId: 'prod-0001-0001-0001-000000000001',
        ),
      ).called(1);
    });

    test(
      'updateProduct deletes old images after DB update succeeds (Bug A)',
      () async {
        final oldProduct = tProduct.copyWith(
          imagePath: '/old/path.jpg',
          imageThumbnailPath: '/old/path_thumb.jpg',
        );
        final updatedProduct = tProduct.copyWith(
          imagePath: '/new/path.jpg',
          imageThumbnailPath: '/new/path_thumb.jpg',
        );
        when(
          () => mockDs.getProductById(any()),
        ).thenAnswer((_) async => oldProduct);
        when(
          () => mockImageService.deleteImages(any(), any()),
        ).thenAnswer((_) async {});
        when(
          () => mockImageService.renameImages(any(), any()),
        ).thenAnswer((_) async => null);
        when(() => mockDs.updateProduct(any())).thenAnswer((_) async {});

        await repo.updateProduct(updatedProduct);

        verifyInOrder([
          () => mockDs.updateProduct(any()),
          () => mockImageService.deleteImages(
            '/old/path.jpg',
            '/old/path_thumb.jpg',
          ),
        ]);
      },
    );

    test(
      'updateProduct does not delete old images when DB update fails (Bug A)',
      () async {
        final oldProduct = tProduct.copyWith(
          imagePath: '/old/path.jpg',
          imageThumbnailPath: '/old/path_thumb.jpg',
        );
        final updatedProduct = tProduct.copyWith(
          imagePath: '/new/path.jpg',
          imageThumbnailPath: '/new/path_thumb.jpg',
        );
        when(
          () => mockDs.getProductById(any()),
        ).thenAnswer((_) async => oldProduct);
        when(
          () => mockImageService.deleteImages(any(), any()),
        ).thenAnswer((_) async {});
        when(
          () => mockImageService.renameImages(any(), any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockDs.updateProduct(any()),
        ).thenThrow(Exception('DB error'));

        expect(
          () => repo.updateProduct(updatedProduct),
          throwsA(isA<Exception>()),
        );

        verifyNever(() => mockImageService.deleteImages(any(), any()));
      },
    );

    test('addProduct cleans up images when insert fails (Bug D)', () async {
      when(() => mockImageService.renameImages(any(), any())).thenAnswer(
        (_) async => const ImagePaths(
          fullPath: '/renamed/path.jpg',
          thumbnailPath: '/renamed/path_thumb.jpg',
        ),
      );
      when(
        () => mockImageService.deleteImages(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockDs.insertProduct(any())).thenThrow(Exception('DB error'));

      try {
        await repo.addProduct(
          name: 'Test',
          price: 100.0,
          stock: 10,
          imagePath: '/temp/path.jpg',
          imageThumbnailPath: '/temp/path_thumb.jpg',
        );
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }

      verify(() => mockImageService.deleteImages(any(), any())).called(1);
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
