import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/inventory/domain/repositories/inventory_log_repository.dart';

@injectable
class WatchInventoryLogs {
  const WatchInventoryLogs(this._repository);
  final InventoryLogRepository _repository;

  Stream<List<InventoryLog>> call({String? productId}) =>
      _repository.watchLogs(productId: productId);
}
