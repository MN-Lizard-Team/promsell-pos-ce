import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/repositories/restaurant_table_repository.dart';

/// Memoized table-id → table-name lookups for display surfaces that persist
/// only the raw table id (draft bills, cart header).
///
/// Draft carts store `tableId`, never the table name — this resolver turns
/// ids back into display names with a process-lifetime cache. Unknown or
/// deleted tables resolve to null so callers can fall back to a short id.
@lazySingleton
class RestaurantTableNameResolver {
  RestaurantTableNameResolver(this._repository);

  final RestaurantTableRepository _repository;
  final Map<String, String?> _cache = {};

  /// Resolved name for [tableId], or null when the id is blank/unknown.
  /// Results are memoized until [invalidate].
  Future<String?> resolve(String tableId) async {
    final id = tableId.trim();
    if (id.isEmpty) return null;
    if (_cache.containsKey(id)) return _cache[id];
    final name = (await _repository.getTableById(id))?.name;
    _cache[id] = name;
    return name;
  }

  /// Drops every memoized name — call after tables are added/renamed/deleted.
  void invalidate() => _cache.clear();
}
