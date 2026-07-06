import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';

abstract class RestaurantTableRepository {
  Future<List<RestaurantTable>> getAllTables();
  Future<RestaurantTable?> getTableById(String id);
  Future<String> addTable({
    required String name,
    String? zone,
    int? seats,
    int sortOrder = 0,
  });
  Future<void> updateTable(RestaurantTable table);
  Future<void> deleteTable(String id);
  Future<void> updateTableStatus(String id, TableStatus status);
}
