import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

abstract class CategoryLocalDatasource {
  Stream<List<CategoryData>> watchAll();
  Future<void> insert(CategoriesCompanion companion);
  Future<void> update(CategoriesCompanion companion);
  Future<void> delete(String id);
  Future<void> deleteWithProductDisposition(
    List<String> categoryIds, {
    String? moveProductsToCategoryId,
  });
  Future<void> reorderAll(List<(String id, int sortOrder)> updates);
}

@LazySingleton(as: CategoryLocalDatasource)
class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  const CategoryLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  @override
  Stream<List<CategoryData>> watchAll() =>
      (_db.select(_db.categories)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .watch();

  @override
  Future<void> insert(CategoriesCompanion companion) =>
      _db.into(_db.categories).insert(companion);

  @override
  Future<void> update(CategoriesCompanion companion) => (_db.update(
    _db.categories,
  )..where((c) => c.id.equals(companion.id.value))).write(companion);

  @override
  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  @override
  Future<void> deleteWithProductDisposition(
    List<String> categoryIds, {
    String? moveProductsToCategoryId,
  }) async {
    final ids = categoryIds.toSet().toList();
    if (ids.isEmpty) return;
    if (moveProductsToCategoryId != null &&
        ids.contains(moveProductsToCategoryId)) {
      throw ArgumentError('The destination category cannot be deleted.');
    }

    await _db.transaction(() async {
      if (moveProductsToCategoryId != null) {
        final destination =
            await (_db.select(_db.categories)..where(
                  (category) =>
                      category.id.equals(moveProductsToCategoryId) &
                      category.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (destination == null) {
          throw ArgumentError('The destination category does not exist.');
        }
      }

      final now = DateTime.now();
      await (_db.update(
        _db.products,
      )..where((product) => product.categoryId.isIn(ids))).write(
        ProductsCompanion(
          categoryId: Value(moveProductsToCategoryId),
          updatedAt: Value(now),
        ),
      );
      // Soft-delete so structure can be recovered from backup-aware flows later.
      await (_db.update(
        _db.categories,
      )..where((category) => category.id.isIn(ids))).write(
        CategoriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    });
  }

  @override
  Future<void> reorderAll(List<(String id, int sortOrder)> updates) =>
      _db.batch((b) {
        for (final (id, sortOrder) in updates) {
          b.update(
            _db.categories,
            CategoriesCompanion(sortOrder: Value(sortOrder)),
            where: (c) => c.id.equals(id),
          );
        }
      });
}
