import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/exceptions/category_exceptions.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_category.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository mockRepo;
  late AddCategory useCase;

  Category cat(String name, int sort) => Category(
    id: 'id-$name',
    name: name,
    sortOrder: sort,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = AddCategory(mockRepo);
    when(
      () => mockRepo.addCategory(
        name: any(named: 'name'),
        sortOrder: any(named: 'sortOrder'),
        color: any(named: 'color'),
        iconName: any(named: 'iconName'),
      ),
    ).thenAnswer((_) async => 'new-id');
  });

  test(
    'throws CategoryNameExistsException on duplicate (case-insensitive)',
    () async {
      when(
        () => mockRepo.watchCategories(),
      ).thenAnswer((_) => Stream.value([cat('Drinks', 1)]));

      expect(
        () => useCase(name: 'drinks'),
        throwsA(isA<CategoryNameExistsException>()),
      );
      verifyNever(
        () => mockRepo.addCategory(
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
          color: any(named: 'color'),
          iconName: any(named: 'iconName'),
        ),
      );
    },
  );

  test('auto sortOrder is 1 when catalog empty and caller passes 0', () async {
    when(() => mockRepo.watchCategories()).thenAnswer((_) => Stream.value([]));

    await useCase(name: '  Snacks  ');

    verify(
      () => mockRepo.addCategory(
        name: 'Snacks',
        sortOrder: 1,
        color: null,
        iconName: null,
      ),
    ).called(1);
  });

  test('auto sortOrder is max+1 when caller passes 0', () async {
    when(
      () => mockRepo.watchCategories(),
    ).thenAnswer((_) => Stream.value([cat('A', 2), cat('B', 5), cat('C', 1)]));

    await useCase(name: 'New');

    verify(
      () => mockRepo.addCategory(
        name: 'New',
        sortOrder: 6,
        color: null,
        iconName: null,
      ),
    ).called(1);
  });

  test('honors explicit non-zero sortOrder', () async {
    when(() => mockRepo.watchCategories()).thenAnswer((_) => Stream.value([]));

    await useCase(name: 'Forced', sortOrder: 99, color: 'E53935');

    verify(
      () => mockRepo.addCategory(
        name: 'Forced',
        sortOrder: 99,
        color: 'E53935',
        iconName: null,
      ),
    ).called(1);
  });
}
