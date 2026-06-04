import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';

abstract class InventoryLogRepository {
  Stream<List<InventoryLog>> watchLogs({String? productId});
}
