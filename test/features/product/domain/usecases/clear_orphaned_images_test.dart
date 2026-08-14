import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/services/orphan_image_cleaner.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/clear_orphaned_images.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class _MockOrphanImageCleaner extends Mock implements OrphanImageCleaner {}

void main() {
  late MockProductRepository mockRepo;
  late _MockOrphanImageCleaner mockImageCleaner;
  late ClearOrphanedImages useCase;

  setUp(() {
    mockRepo = MockProductRepository();
    mockImageCleaner = _MockOrphanImageCleaner();
    useCase = ClearOrphanedImages(mockRepo, mockImageCleaner);
  });

  test('collects valid paths and delegates to imageCleaner', () async {
    final products = [
      Product(
        id: 'p1',
        name: 'A',
        price: Money.fromDouble(10),
        stock: 5,
        isActive: true,
        imagePath: '/images/p1.jpg',
        imageThumbnailPath: '/images/p1_thumb.jpg',
        createdAt: tNow,
        updatedAt: tNow,
      ),
      Product(
        id: 'p2',
        name: 'B',
        price: Money.fromDouble(20),
        stock: 3,
        isActive: true,
        imagePath: null,
        imageThumbnailPath: null,
        createdAt: tNow,
        updatedAt: tNow,
      ),
    ];

    when(() => mockRepo.getActiveProducts()).thenAnswer((_) async => products);
    when(
      () => mockImageCleaner.clearOrphanedImages(any()),
    ).thenAnswer((_) async => 5);

    final result = await useCase();

    expect(result, 5);
    verify(
      () => mockImageCleaner.clearOrphanedImages([
        '/images/p1.jpg',
        '/images/p1_thumb.jpg',
      ]),
    ).called(1);
  });

  test('handles empty product list', () async {
    when(() => mockRepo.getActiveProducts()).thenAnswer((_) async => []);
    when(
      () => mockImageCleaner.clearOrphanedImages(any()),
    ).thenAnswer((_) async => 0);

    final result = await useCase();

    expect(result, 0);
    verify(() => mockImageCleaner.clearOrphanedImages([])).called(1);
  });

  test('skips empty string paths', () async {
    final products = [
      Product(
        id: 'p1',
        name: 'A',
        price: Money.fromDouble(10),
        stock: 5,
        isActive: true,
        imagePath: '',
        imageThumbnailPath: '',
        createdAt: tNow,
        updatedAt: tNow,
      ),
    ];

    when(() => mockRepo.getActiveProducts()).thenAnswer((_) async => products);
    when(
      () => mockImageCleaner.clearOrphanedImages(any()),
    ).thenAnswer((_) async => 3);

    final result = await useCase();

    expect(result, 3);
    verify(() => mockImageCleaner.clearOrphanedImages([])).called(1);
  });
}
