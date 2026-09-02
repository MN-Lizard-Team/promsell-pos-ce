import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();
  @override
  List<Object?> get props => [];
}

class TablesLoaded extends TableEvent {
  const TablesLoaded();
}

/// Internal bridge: emitted for every emission of the repository watch
/// stream so live effective statuses reach [TableState.tables].
class TablesWatchRefreshed extends TableEvent {
  const TablesWatchRefreshed(this.tables);
  final List<RestaurantTable> tables;
  @override
  List<Object?> get props => [tables];
}

class TableAdded extends TableEvent {
  const TableAdded({
    required this.name,
    this.zone,
    this.seats,
    this.sortOrder = 0,
  });
  final String name;
  final String? zone;
  final int? seats;
  final int sortOrder;
  @override
  List<Object?> get props => [name, zone, seats, sortOrder];
}

class TableUpdated extends TableEvent {
  const TableUpdated(this.table);
  final RestaurantTable table;
  @override
  List<Object?> get props => [table];
}

class TableDeleted extends TableEvent {
  const TableDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class TableStatusChanged extends TableEvent {
  const TableStatusChanged({required this.id, required this.status});
  final String id;
  final TableStatus status;
  @override
  List<Object?> get props => [id, status];
}
