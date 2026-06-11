import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

abstract class CategoryLocalDatasource {
  Stream<List<CategoryData>> watchAll();
  Future<void> insert(CategoriesCompanion companion);
  Future<void> update(CategoriesCompanion companion);
  Future<void> delete(String id);
}

@LazySingleton(as: CategoryLocalDatasource)
class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  const CategoryLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  @override
  Stream<List<CategoryData>> watchAll() => (_db.select(
    _db.categories,
  )..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).watch();

  @override
  Future<void> insert(CategoriesCompanion companion) =>
      _db.into(_db.categories).insert(companion);

  @override
  Future<void> update(CategoriesCompanion companion) => (_db.update(
    _db.categories,
  )..where((c) => c.id.equals(companion.id.value))).write(companion);

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
}
