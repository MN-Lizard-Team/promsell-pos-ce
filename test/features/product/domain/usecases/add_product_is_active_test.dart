import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_product.dart';

import '../../../../helpers/fake_app_lock.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockRepo;
  late AppLockService appLock;
  late AddProduct useCase;

  setUp(() {
    mockRepo = MockProductRepository();
    appLock = fakeAppLock();
    useCase = AddProduct(mockRepo, appLock);
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
  });

  test('forwards isActive: false to repository', () async {
    await useCase(name: 'Hidden', price: 10, stock: 1, isActive: false);

    final captured = verify(
      () => mockRepo.addProduct(
        name: 'Hidden',
        price: 10,
        stock: 1,
        sku: any(named: 'sku'),
        barcode: any(named: 'barcode'),
        cost: any(named: 'cost'),
        categoryId: any(named: 'categoryId'),
        imageUrl: any(named: 'imageUrl'),
        imagePath: any(named: 'imagePath'),
        imageThumbnailPath: any(named: 'imageThumbnailPath'),
        trackStock: any(named: 'trackStock'),
        isActive: captureAny(named: 'isActive'),
        description: any(named: 'description'),
        brand: any(named: 'brand'),
        unit: any(named: 'unit'),
        supplier: any(named: 'supplier'),
        isRecommended: any(named: 'isRecommended'),
        optionGroups: any(named: 'optionGroups'),
      ),
    ).captured;

    expect(captured.single, isFalse);
  });
}
