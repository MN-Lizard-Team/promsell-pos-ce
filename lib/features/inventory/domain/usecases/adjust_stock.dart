import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/inventory/domain/repositories/inventory_repository.dart';

@injectable
class AdjustStock {
  const AdjustStock(this._repository, this._appLock);
  final InventoryRepository _repository;
  final AppLockService _appLock;

  /// Adjust stock for [productId] by [qtyChange] (positive = add, negative = remove).
  /// [reason] is required for audit trail.
  /// Throws [StateError] if product not found or result stock < 0.
  /// Throws [BusinessRuleError] `AppLockRequired` when store PIN is on and session locked.
  Future<void> call({
    required String productId,
    required int qtyChange,
    required String reason,
  }) async {
    await _appLock.requireSensitiveSession();
    return _repository.adjustStock(
      productId: productId,
      qtyChange: qtyChange,
      reason: reason,
    );
  }
}
