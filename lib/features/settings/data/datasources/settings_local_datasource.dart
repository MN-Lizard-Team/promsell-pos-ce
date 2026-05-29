import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

abstract interface class SettingsLocalDatasource {
  Future<String?> getString(String key);
  Future<int?> getInt(String key);
  Future<bool?> getBool(String key);
  Future<double?> getDouble(String key);
  Future<void> setString(String key, String value);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);
  Future<void> setDouble(String key, double value);
  Future<Map<String, String>> getAll();
}

@LazySingleton(as: SettingsLocalDatasource)
class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  SettingsLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  @override
  Future<String?> getString(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<int?> getInt(String key) async {
    final raw = await getString(key);
    return raw == null ? null : int.tryParse(raw);
  }

  @override
  Future<bool?> getBool(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    return raw == 'true' || raw == '1';
  }

  @override
  Future<double?> getDouble(String key) async {
    final raw = await getString(key);
    return raw == null ? null : double.tryParse(raw);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  @override
  Future<void> setInt(String key, int value) =>
      setString(key, value.toString());

  @override
  Future<void> setBool(String key, bool value) =>
      setString(key, value.toString());

  @override
  Future<void> setDouble(String key, double value) =>
      setString(key, value.toString());

  @override
  Future<Map<String, String>> getAll() async {
    final rows = await _db.select(_db.appSettings).get();
    return {for (final r in rows) r.key: r.value};
  }
}
