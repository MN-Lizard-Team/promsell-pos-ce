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

  /// Active draft cart bound to a table (same predicate as the partial
  /// unique index `idx_draft_carts_table_id_unique`).
  Expression<bool> _activeCartBoundToTable() =>
      _db.draftCarts.tableId.equalsExp(_db.restaurantTables.id) &
      _db.draftCarts.isArchived.equals(false) &
      _db.draftCarts.deletedAt.isNull();

  JoinedSelectStatement _tablesJoinedToActiveCarts() {
    return _db.select(_db.restaurantTables).join([
        // The unique index guarantees ≤1 active cart per table, so the join
        // emits exactly one row per table (cart side null when free).
        //
        // Columns MUST be selected (useColumns defaults to true): drift only
        // populates TypedResult.readTableOrNull for joined tables whose
        // columns are part of the SELECT.
        leftOuterJoin(_db.draftCarts, _activeCartBoundToTable()),
      ])
      ..where(_db.restaurantTables.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.restaurantTables.sortOrder)]);
  }

  @override
  Stream<List<RestaurantTable>> watchTables() {
    return _tablesJoinedToActiveCarts().watch().map(
      (rows) => rows.map(_rowToEntity).toList(),
    );
  }

  @override
  Future<List<RestaurantTable>> getAllTables() async {
    final rows = await _tablesJoinedToActiveCarts().get();
    return rows.map(_rowToEntity).toList();
  }

  @override
  Future<RestaurantTable?> getTableById(String id) async {
    final query = _tablesJoinedToActiveCarts()
      ..where(_db.restaurantTables.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _rowToEntity(rows.single);
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
        // Only the manual available/reserved choice is persisted; occupancy
        // is derived from active draft carts, never stored.
        status: Value(table.manualStatus.name),
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

  RestaurantTable _rowToEntity(TypedResult row) {
    final d = row.readTable(_db.restaurantTables);
    final boundCart = row.readTableOrNull(_db.draftCarts);
    var manual = TableStatus.values.byName(d.status);
    if (manual == TableStatus.occupied) {
      // Legacy stored value — occupancy is derived now, not stored.
      manual = TableStatus.available;
    }
    return RestaurantTable(
      id: d.id,
      name: d.name,
      zone: d.zone,
      seats: d.seats,
      status: boundCart != null ? TableStatus.occupied : manual,
      manualStatus: manual,
      sortOrder: d.sortOrder,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }
}
