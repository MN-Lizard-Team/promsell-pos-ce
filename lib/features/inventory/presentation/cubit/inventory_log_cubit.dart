import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_state.dart';

@injectable
class InventoryLogCubit extends Cubit<InventoryLogState> {
  InventoryLogCubit({required WatchInventoryLogs watchInventoryLogs})
    : _watchInventoryLogs = watchInventoryLogs,
      super(const InventoryLogState());

  final WatchInventoryLogs _watchInventoryLogs;
  StreamSubscription<List<InventoryLog>>? _sub;

  void load({String? productId}) {
    emit(const InventoryLogState(status: InventoryLogStatus.loading));
    _sub?.cancel();
    _sub = _watchInventoryLogs(productId: productId).listen(
      (logs) => emit(
        InventoryLogState(status: InventoryLogStatus.success, logs: logs),
      ),
      onError: (Object e) => emit(
        InventoryLogState(
          status: InventoryLogStatus.failure,
          errorMessage: e.toString(),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
