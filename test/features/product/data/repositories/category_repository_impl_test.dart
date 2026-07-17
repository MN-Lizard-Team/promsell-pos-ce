import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/category_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/repositories/category_repository_impl.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late CategoryLocalDatasourceImpl datasource;
  late CategoryRepositoryImpl repo;

  setUp(() {
    db = createInMemoryDatabase();
    datasource = CategoryLocalDatasourceImpl(db);
    repo = CategoryRepositoryImpl(datasource);
  });

  tearDown(() => db.close());

  group('CategoryRepositoryImpl', () {
    test('addCategory inserts and watchCategories emits', () async {
      final stream = repo.watchCategories();
      final future = stream.first;

      await repo.addCategory(name: 'Drinks', sortOrder: 1);

      final categories = await future;
      expect(categories, hasLength(1));
      expect(categories.first.name, 'Drinks');
      expect(categories.first.sortOrder, 1);
    });

    test('updateCategory updates name and sortOrder', () async {
      await repo.addCategory(name: 'Food');
      final first = await repo.watchCategories().first;
      final catId = first.first.id;

      await repo.updateCategory(
        Category(
          id: catId,
          name: 'Snacks',
          sortOrder: 5,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      final updated = await repo.watchCategories().first;
      expect(updated.first.name, 'Snacks');
      expect(updated.first.sortOrder, 5);
    });

    test('deleteCategory soft-deletes (hidden from watch)', () async {
      await repo.addCategory(name: 'Drinks');
      final first = await repo.watchCategories().first;
      final catId = first.first.id;

      await repo.deleteCategory(catId);

      final after = await repo.watchCategories().first;
      expect(after, isEmpty);

      // Row still exists with deletedAt set.
      final row = await (db.select(
        db.categories,
      )..where((c) => c.id.equals(catId))).getSingle();
      expect(row.deletedAt != null, isTrue);
    });

    test('reorderCategories updates sortOrder for all', () async {
      await repo.addCategory(name: 'A', sortOrder: 0);
      await repo.addCategory(name: 'B', sortOrder: 1);
      await repo.addCategory(name: 'C', sortOrder: 2);

      final first = await repo.watchCategories().first;
      final ids = first.map((c) => c.id).toList();
      final reordered = ids.reversed.toList();

      await repo.reorderCategories(reordered);

      final after = await repo.watchCategories().first;
      expect(after.map((c) => c.name).toList(), ['C', 'B', 'A']);
    });

    test('watchCategories orders by sortOrder ascending', () async {
      await repo.addCategory(name: 'Z', sortOrder: 3);
      await repo.addCategory(name: 'A', sortOrder: 1);
      await repo.addCategory(name: 'M', sortOrder: 2);

      final categories = await repo.watchCategories().first;
      expect(categories.map((c) => c.name).toList(), ['A', 'M', 'Z']);
    });

    test(
      'deleteCategories null disposition uncategorized products then removes cats',
      () async {
        await repo.addCategory(name: 'Drinks', sortOrder: 1);
        await repo.addCategory(name: 'Food', sortOrder: 2);
        final cats = await repo.watchCategories().first;
        final drinksId = cats.firstWhere((c) => c.name == 'Drinks').id;
        final foodId = cats.firstWhere((c) => c.name == 'Food').id;

        await db
            .into(db.products)
            .insert(
              ProductsCompanion.insert(
                id: 'p1',
                name: 'Coffee',
                price: 50,
                categoryId: Value(drinksId),
              ),
            );

        await repo.deleteCategories([drinksId], moveProductsToCategoryId: null);

        final afterCats = await repo.watchCategories().first;
        expect(afterCats.map((c) => c.id), [foodId]);

        final product = await (db.select(
          db.products,
        )..where((p) => p.id.equals('p1'))).getSingle();
        expect(product.categoryId, equals(null));
      },
    );

    test(
      'deleteCategories moves products to destination then removes cats',
      () async {
        await repo.addCategory(name: 'Drinks', sortOrder: 1);
        await repo.addCategory(name: 'Food', sortOrder: 2);
        final cats = await repo.watchCategories().first;
        final drinksId = cats.firstWhere((c) => c.name == 'Drinks').id;
        final foodId = cats.firstWhere((c) => c.name == 'Food').id;

        await db
            .into(db.products)
            .insert(
              ProductsCompanion.insert(
                id: 'p2',
                name: 'Tea',
                price: 40,
                categoryId: Value(drinksId),
              ),
            );

        await repo.deleteCategories([
          drinksId,
        ], moveProductsToCategoryId: foodId);

        final afterCats = await repo.watchCategories().first;
        expect(afterCats.map((c) => c.id), [foodId]);

        final product = await (db.select(
          db.products,
        )..where((p) => p.id.equals('p2'))).getSingle();
        expect(product.categoryId, foodId);
      },
    );
  });
}
