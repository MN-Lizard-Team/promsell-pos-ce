import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/import_products.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockAddCategory extends Mock implements AddCategory {}

void main() {
  late MockProductRepository products;
  late MockCategoryRepository categories;
  late MockAddCategory addCategory;
  late ImportProducts useCase;

  setUp(() {
    products = MockProductRepository();
    categories = MockCategoryRepository();
    addCategory = MockAddCategory();
    useCase = ImportProducts(products, categories, addCategory);

    when(
      () => categories.watchCategories(),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => products.addProduct(
        name: any(named: 'name'),
        sku: any(named: 'sku'),
        barcode: any(named: 'barcode'),
        price: any(named: 'price'),
        cost: any(named: 'cost'),
        stock: any(named: 'stock'),
        categoryId: any(named: 'categoryId'),
        trackStock: any(named: 'trackStock'),
      ),
    ).thenAnswer((_) async => 'p1');
  });

  test('creates missing category via AddCategory and reuses id', () async {
    when(
      () => addCategory(
        name: any(named: 'name'),
        sortOrder: any(named: 'sortOrder'),
        color: any(named: 'color'),
        iconName: any(named: 'iconName'),
      ),
    ).thenAnswer((_) async => 'cat-new');

    final result = await useCase([
      const CsvProductRow(
        sourceRow: 2,
        name: 'Coffee',
        price: 50,
        categoryName: 'Drinks',
      ),
      const CsvProductRow(
        sourceRow: 3,
        name: 'Tea',
        price: 40,
        categoryName: 'Drinks',
      ),
    ]);

    expect(result.importedCount, 2);
    expect(result.createdCategoryCount, 1);
    verify(
      () => addCategory(
        name: 'Drinks',
        sortOrder: any(named: 'sortOrder'),
        color: any(named: 'color'),
        iconName: any(named: 'iconName'),
      ),
    ).called(1);
    verify(
      () => products.addProduct(
        name: 'Coffee',
        sku: any(named: 'sku'),
        barcode: any(named: 'barcode'),
        price: 50,
        cost: any(named: 'cost'),
        stock: any(named: 'stock'),
        categoryId: 'cat-new',
        trackStock: any(named: 'trackStock'),
      ),
    ).called(1);
  });

  test('reuses existing category without calling AddCategory', () async {
    when(() => categories.watchCategories()).thenAnswer(
      (_) => Stream.value([
        Category(
          id: 'cat-1',
          name: 'Drinks',
          sortOrder: 1,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ]),
    );

    final result = await useCase([
      const CsvProductRow(
        sourceRow: 2,
        name: 'Coffee',
        price: 50,
        categoryName: 'drinks',
      ),
    ]);

    expect(result.importedCount, 1);
    expect(result.createdCategoryCount, 0);
    verifyNever(
      () => addCategory(
        name: any(named: 'name'),
        sortOrder: any(named: 'sortOrder'),
        color: any(named: 'color'),
        iconName: any(named: 'iconName'),
      ),
    );
    verify(
      () => products.addProduct(
        name: 'Coffee',
        sku: any(named: 'sku'),
        barcode: any(named: 'barcode'),
        price: 50,
        cost: any(named: 'cost'),
        stock: any(named: 'stock'),
        categoryId: 'cat-1',
        trackStock: any(named: 'trackStock'),
      ),
    ).called(1);
  });
}
