import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/clear_orphaned_images.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockRepo;
  late MockProductImageService mockImageService;
  late ClearOrphanedImages useCase;

  setUp(() {
    mockRepo = MockProductRepository();
    mockImageService = MockProductImageService();
    useCase = ClearOrphanedImages(mockRepo, mockImageService);
  });

  test('collects valid paths and delegates to imageService', () async {
    final products = [
      Product(
        id: 'p1',
        name: 'A',
        price: 10,
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
        price: 20,
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
      () => mockImageService.clearOrphanedImages(any()),
    ).thenAnswer((_) async => 5);

    final result = await useCase();

    expect(result, 5);
    verify(
      () => mockImageService.clearOrphanedImages([
        '/images/p1.jpg',
        '/images/p1_thumb.jpg',
      ]),
    ).called(1);
  });

  test('handles empty product list', () async {
    when(() => mockRepo.getActiveProducts()).thenAnswer((_) async => []);
    when(
      () => mockImageService.clearOrphanedImages(any()),
    ).thenAnswer((_) async => 0);

    final result = await useCase();

    expect(result, 0);
    verify(() => mockImageService.clearOrphanedImages([])).called(1);
  });

  test('skips empty string paths', () async {
    final products = [
      Product(
        id: 'p1',
        name: 'A',
        price: 10,
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
      () => mockImageService.clearOrphanedImages(any()),
    ).thenAnswer((_) async => 3);

    final result = await useCase();

    expect(result, 3);
    verify(() => mockImageService.clearOrphanedImages([])).called(1);
  });
}
