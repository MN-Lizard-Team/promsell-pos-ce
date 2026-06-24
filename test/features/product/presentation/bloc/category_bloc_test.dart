import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/reorder_categories.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/watch_categories.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';

class MockWatchCategories extends Mock implements WatchCategories {}

class MockAddCategory extends Mock implements AddCategory {}

class MockUpdateCategory extends Mock implements UpdateCategory {}

class MockDeleteCategory extends Mock implements DeleteCategory {}

class MockReorderCategories extends Mock implements ReorderCategories {}

void main() {
  late MockWatchCategories mockWatch;
  late MockAddCategory mockAdd;
  late MockUpdateCategory mockUpdate;
  late MockDeleteCategory mockDelete;
  late MockReorderCategories mockReorder;

  final tCategory = Category(
    id: 'cat-001',
    name: 'Drinks',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
  final tCategories = [tCategory];

  CategoryState successState([CategorySaveStatus? saveStatus]) => CategoryState(
    status: CategoryStatus.success,
    categories: tCategories,
    saveStatus: saveStatus ?? CategorySaveStatus.idle,
  );

  setUpAll(() {
    registerFallbackValue(tCategory);
  });

  setUp(() {
    mockWatch = MockWatchCategories();
    mockAdd = MockAddCategory();
    mockUpdate = MockUpdateCategory();
    mockDelete = MockDeleteCategory();
    mockReorder = MockReorderCategories();

    when(() => mockWatch()).thenAnswer((_) => const Stream.empty());
  });

  CategoryBloc buildBloc() => CategoryBloc(
    watchCategories: mockWatch,
    addCategory: mockAdd,
    updateCategory: mockUpdate,
    deleteCategory: mockDelete,
    reorderCategories: mockReorder,
  );

  blocTest<CategoryBloc, CategoryState>(
    'emits success with categories from watch stream',
    build: () {
      when(() => mockWatch()).thenAnswer((_) => Stream.value([tCategory]));
      return CategoryBloc(
        watchCategories: mockWatch,
        addCategory: mockAdd,
        updateCategory: mockUpdate,
        deleteCategory: mockDelete,
        reorderCategories: mockReorder,
      );
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [successState()],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoryAdded emits saving then saved',
    build: buildBloc,
    act: (bloc) {
      when(
        () => mockAdd(
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
          color: any(named: 'color'),
          iconName: any(named: 'iconName'),
        ),
      ).thenAnswer((_) async {});
      bloc.add(const CategoryAdded(name: 'Snacks'));
    },
    wait: const Duration(milliseconds: 150),
    expect: () => [
      const CategoryState(saveStatus: CategorySaveStatus.saving),
      const CategoryState(saveStatus: CategorySaveStatus.saved),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoryAdded emits error on failure',
    build: buildBloc,
    act: (bloc) {
      when(
        () => mockAdd(
          name: any(named: 'name'),
          sortOrder: any(named: 'sortOrder'),
          color: any(named: 'color'),
          iconName: any(named: 'iconName'),
        ),
      ).thenThrow(Exception('add failed'));
      bloc.add(const CategoryAdded(name: 'Snacks'));
    },
    wait: const Duration(milliseconds: 150),
    expect: () => [
      const CategoryState(saveStatus: CategorySaveStatus.saving),
      const CategoryState(
        saveStatus: CategorySaveStatus.error,
        errorMessage: 'Exception: add failed',
      ),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoryUpdated emits saving then saved',
    build: buildBloc,
    act: (bloc) {
      when(() => mockUpdate(any())).thenAnswer((_) async {});
      bloc.add(CategoryUpdated(tCategory));
    },
    wait: const Duration(milliseconds: 150),
    expect: () => [
      const CategoryState(saveStatus: CategorySaveStatus.saving),
      const CategoryState(saveStatus: CategorySaveStatus.saved),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoryDeleted emits saving then saved',
    build: buildBloc,
    act: (bloc) {
      when(() => mockDelete(any())).thenAnswer((_) async {});
      bloc.add(const CategoryDeleted('cat-001'));
    },
    wait: const Duration(milliseconds: 150),
    expect: () => [
      const CategoryState(saveStatus: CategorySaveStatus.saving),
      const CategoryState(saveStatus: CategorySaveStatus.saved),
    ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoriesReordered emits saving then saved',
    build: buildBloc,
    act: (bloc) {
      when(() => mockReorder(any())).thenAnswer((_) async {});
      bloc.add(const CategoriesReordered(['cat-001']));
    },
    wait: const Duration(milliseconds: 150),
    expect: () => [
      const CategoryState(saveStatus: CategorySaveStatus.saving),
      const CategoryState(saveStatus: CategorySaveStatus.saved),
    ],
  );

  group('CategoryEvent equality', () {
    test('CategoryAdded props', () {
      const a = CategoryAdded(name: 'A', sortOrder: 1);
      const b = CategoryAdded(name: 'A', sortOrder: 1);
      const c = CategoryAdded(name: 'B', sortOrder: 1);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CategoryUpdated props', () {
      final cat = Category(
        id: 'c1',
        name: 'A',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      final a = CategoryUpdated(cat);
      final b = CategoryUpdated(cat);
      expect(a, equals(b));
    });

    test('CategoryDeleted props', () {
      const a = CategoryDeleted('c1');
      const b = CategoryDeleted('c1');
      const c = CategoryDeleted('c2');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CategoriesReordered props', () {
      const a = CategoriesReordered(['c1', 'c2']);
      const b = CategoriesReordered(['c1', 'c2']);
      const c = CategoriesReordered(['c2', 'c1']);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
