import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_product.dart';

import '../../../../helpers/fake_app_lock.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

/// Returns an [AppLockService] with PIN enabled and session locked.
Future<AppLockService> _lockedAppLock() async {
  final lock = fakeAppLock();
  await lock.setPin('147258');
  lock.lockSession();
  return lock;
}

void main() {
  late MockProductRepository mockRepo;
  late AppLockService appLock;

  setUp(() {
    mockRepo = MockProductRepository();
    appLock = fakeAppLock();
  });

  setUpAll(() {
    registerFallbackValue(tProduct);
  });

  group('AddProduct', () {
    late AddProduct useCase;
    setUp(() => useCase = AddProduct(mockRepo, appLock));

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

      await expectLater(
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

    // V092-B.1 regression: gate refuses when non-default money/stock + locked.
    test('throws BusinessRuleError AppLockRequired when PIN on, locked, and '
        'non-default price/stock/cost', () async {
      final locked = await _lockedAppLock();
      final gated = AddProduct(mockRepo, locked);

      await expectLater(
        () => gated(name: 'Test', price: 100.0, stock: 10),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            AppLockService.ruleAppLockRequired,
          ),
        ),
      );
      verifyNever(
        () => mockRepo.addProduct(
          name: any(named: 'name'),
          price: any(named: 'price'),
          stock: any(named: 'stock'),
        ),
      );
    });

    // V092-B.1: passes when PIN is off (default fakeAppLock state).
    test('passes through when PIN is off', () async {
      when(
        () => mockRepo.addProduct(
          name: any(named: 'name'),
          price: any(named: 'price'),
          stock: any(named: 'stock'),
          sku: any(named: 'sku'),
          barcode: any(named: 'barcode'),
          cost: any(named: 'cost'),
          categoryId: any(named: 'categoryId'),
          imageUrl: any(named: 'imageUrl'),
          imagePath: any(named: 'imagePath'),
          imageThumbnailPath: any(named: 'imageThumbnailPath'),
          trackStock: any(named: 'trackStock'),
          isActive: any(named: 'isActive'),
          description: any(named: 'description'),
          brand: any(named: 'brand'),
          unit: any(named: 'unit'),
          supplier: any(named: 'supplier'),
          isRecommended: any(named: 'isRecommended'),
          optionGroups: any(named: 'optionGroups'),
        ),
      ).thenAnswer((_) async => 'id-1');

      final result = await useCase(name: 'Test', price: 100.0, stock: 10);

      expect(result, 'id-1');
    });
  });

  group('UpdateProduct', () {
    late UpdateProduct useCase;
    setUp(() => useCase = UpdateProduct(mockRepo, appLock));

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

        await expectLater(
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
