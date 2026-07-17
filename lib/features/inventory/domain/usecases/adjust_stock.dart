import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/inventory/domain/repositories/inventory_repository.dart';

@injectable
class AdjustStock {
  const AdjustStock(this._repository);
  final InventoryRepository _repository;

  /// Adjust stock for [productId] by [qtyChange] (positive = add, negative = remove).
  /// [reason] is required for audit trail.
  /// Throws [StateError] if product not found or result stock < 0.
  Future<void> call({
    required String productId,
    required int qtyChange,
    required String reason,
  }) {
    return _repository.adjustStock(
      productId: productId,
      qtyChange: qtyChange,
      reason: reason,
    );
  }
}
