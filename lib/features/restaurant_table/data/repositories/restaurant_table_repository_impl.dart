import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/repositories/restaurant_table_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton(as: RestaurantTableRepository)
class RestaurantTableRepositoryImpl implements RestaurantTableRepository {
  RestaurantTableRepositoryImpl(this._db, {required this.settingsRepo});
  final AppDatabase _db;
  final SettingsRepository settingsRepo;

  String? _cachedDeviceId;
  Future<String> _getDeviceId() async {
    return _cachedDeviceId ??=
        (await settingsRepo.load()).deviceConfig.deviceId;
  }

  @override
  Future<List<RestaurantTable>> getAllTables() async {
    final rows =
        await (_db.select(_db.restaurantTables)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<RestaurantTable?> getTableById(String id) async {
    final row = await (_db.select(
      _db.restaurantTables,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<String> addTable({
    required String name,
    String? zone,
    int? seats,
    int sortOrder = 0,
  }) async {
    final id = IdGenerator.newId();
    final deviceId = await _getDeviceId();
    await _db
        .into(_db.restaurantTables)
        .insert(
          RestaurantTablesCompanion.insert(
            id: id,
            name: name,
            zone: Value(zone),
            seats: Value(seats),
            sortOrder: Value(sortOrder),
            deviceId: Value(deviceId),
          ),
        );
    return id;
  }

  @override
  Future<void> updateTable(RestaurantTable table) async {
    await (_db.update(
      _db.restaurantTables,
    )..where((t) => t.id.equals(table.id))).write(
      RestaurantTablesCompanion(
        name: Value(table.name),
        zone: Value(table.zone),
        seats: Value(table.seats),
        status: Value(table.status.name),
        sortOrder: Value(table.sortOrder),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteTable(String id) async {
    await (_db.update(
      _db.restaurantTables,
    )..where((t) => t.id.equals(id))).write(
      RestaurantTablesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateTableStatus(String id, TableStatus status) async {
    await (_db.update(
      _db.restaurantTables,
    )..where((t) => t.id.equals(id))).write(
      RestaurantTablesCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  RestaurantTable _toEntity(RestaurantTableData d) => RestaurantTable(
    id: d.id,
    name: d.name,
    zone: d.zone,
    seats: d.seats,
    status: TableStatus.values.byName(d.status),
    sortOrder: d.sortOrder,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );
}
