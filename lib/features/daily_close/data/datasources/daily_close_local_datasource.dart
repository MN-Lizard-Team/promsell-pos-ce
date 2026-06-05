import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

abstract class DailyCloseLocalDatasource {
  Future<DailyCloseData?> getByDate(String date);
  Future<List<DailyCloseData>> getAll();
  Future<DailyCloseData> save(DailyCloseData data);
  Future<void> delete(String id);
}

@LazySingleton(as: DailyCloseLocalDatasource)
class DailyCloseLocalDatasourceImpl implements DailyCloseLocalDatasource {
  DailyCloseLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  @override
  Future<DailyCloseData?> getByDate(String date) async {
    return await (_db.select(
      _db.dailyCloses,
    )..where((c) => c.closeDate.equals(date))).getSingleOrNull();
  }

  @override
  Future<List<DailyCloseData>> getAll() async {
    return await (_db.select(
      _db.dailyCloses,
    )..orderBy([(c) => OrderingTerm.desc(c.closeDate)])).get();
  }

  @override
  Future<DailyCloseData> save(DailyCloseData data) async {
    await _db
        .into(_db.dailyCloses)
        .insertOnConflictUpdate(data.toCompanion(false));
    final result = await (_db.select(
      _db.dailyCloses,
    )..where((c) => c.id.equals(data.id))).getSingle();
    return result;
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.dailyCloses)..where((c) => c.id.equals(id))).go();
  }
}
