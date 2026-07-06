import 'package:equatable/equatable.dart';

enum TableStatus { available, occupied, reserved }

class RestaurantTable extends Equatable {
  const RestaurantTable({
    required this.id,
    required this.name,
    this.zone,
    this.seats,
    this.status = TableStatus.available,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? zone;
  final int? seats;
  final TableStatus status;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantTable copyWith({
    String? id,
    String? name,
    String? zone,
    int? seats,
    TableStatus? status,
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
    sortOrder,
    createdAt,
    updatedAt,
  ];
}
