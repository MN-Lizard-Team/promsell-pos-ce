import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';

enum TableBlocStatus { initial, loading, loaded, saving, saved, failure }

class TableState extends Equatable {
  const TableState({
    this.status = TableBlocStatus.initial,
    this.tables = const [],
    this.errorMessage,
  });

  final TableBlocStatus status;
  final List<RestaurantTable> tables;
  final String? errorMessage;

  TableState copyWith({
    TableBlocStatus? status,
    List<RestaurantTable>? tables,
    String? errorMessage,
  }) {
    return TableState(
      status: status ?? this.status,
      tables: tables ?? this.tables,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tables, errorMessage];
}
