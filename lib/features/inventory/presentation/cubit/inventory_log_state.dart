import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';

enum InventoryLogStatus { initial, loading, success, failure }

class InventoryLogState extends Equatable {
  const InventoryLogState({
    this.status = InventoryLogStatus.initial,
    this.logs = const [],
    this.errorMessage,
  });

  final InventoryLogStatus status;
  final List<InventoryLog> logs;
  final String? errorMessage;

  InventoryLogState copyWith({
    InventoryLogStatus? status,
    List<InventoryLog>? logs,
    String? errorMessage,
  }) => InventoryLogState(
    status: status ?? this.status,
    logs: logs ?? this.logs,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, logs, errorMessage];
}
