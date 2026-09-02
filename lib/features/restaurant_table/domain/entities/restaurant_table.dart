import 'package:equatable/equatable.dart';

enum TableStatus { available, occupied, reserved }

class RestaurantTable extends Equatable {
  const RestaurantTable({
    required this.id,
    required this.name,
    this.zone,
    this.seats,
    this.status = TableStatus.available,
    this.manualStatus = TableStatus.available,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? zone;
  final int? seats;

  /// EFFECTIVE status shown to users: [TableStatus.occupied] while at least
  /// one active draft cart binds this table, otherwise [manualStatus].
  /// Derived from the database on every read/watch — never persisted.
  final TableStatus status;

  /// Stored `status` column value. Holds ONLY the manual available/reserved
  /// choice going forward; a legacy stored `occupied` is normalized to
  /// available on read because it is no longer backed by cart occupancy.
  final TableStatus manualStatus;

  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantTable copyWith({
    String? id,
    String? name,
    String? zone,
    int? seats,
    TableStatus? status,
    TableStatus? manualStatus,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      name: name ?? this.name,
      zone: zone ?? this.zone,
      seats: seats ?? this.seats,
      status: status ?? this.status,
      manualStatus: manualStatus ?? this.manualStatus,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    zone,
    seats,
    status,
    manualStatus,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}
