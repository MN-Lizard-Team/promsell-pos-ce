import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';

abstract class InventoryRepository {
  /// Adjust stock for a product by [qtyChange] (+ add, - remove).
  /// Creates an audit log entry.
  /// Throws [StateError] if product not found or resulting stock < 0.
  Future<void> adjustStock({
    required String productId,
    required int qtyChange,
    required String reason,
  });

  /// Get inventory logs for a specific product.
  Stream<List<InventoryLog>> watchInventoryLogs(String productId);

  /// Get all inventory logs (for reports).
  Future<List<InventoryLog>> getAllLogs({
    DateTime? startDate,
    DateTime? endDate,
  });
}
