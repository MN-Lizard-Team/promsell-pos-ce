import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/transaction_event_writer.dart';

abstract class DailyCloseLocalDatasource {
  Future<DailyCloseData?> getByDate(String date);
  Future<List<DailyCloseData>> getAll();
  Future<DailyCloseData> save(DailyCloseData data);
  Future<void> delete(String id);
}

@LazySingleton(as: DailyCloseLocalDatasource)
class DailyCloseLocalDatasourceImpl implements DailyCloseLocalDatasource {
  DailyCloseLocalDatasourceImpl(this._db)
    : _eventWriter = TransactionEventWriter(_db);
  final AppDatabase _db;
  final TransactionEventWriter _eventWriter;

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
    return _db.transaction(() async {
      await _db
          .into(_db.dailyCloses)
          .insertOnConflictUpdate(data.toCompanion(false));
      await _eventWriter.append(
        aggregateType: 'DAILY_CLOSE',
        aggregateId: data.id,
        eventType: data.closedAt == null ? 'DAY_REOPENED' : 'DAY_CLOSED',
        deviceId: data.deviceId,
        afterStatus: data.closedAt == null ? 'OPEN' : 'CLOSED',
        reason: data.note,
        occurredAt: data.updatedAt,
      );
      return (_db.select(
        _db.dailyCloses,
      )..where((c) => c.id.equals(data.id))).getSingle();
    });
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.dailyCloses)..where((c) => c.id.equals(id))).go();
  }
}
