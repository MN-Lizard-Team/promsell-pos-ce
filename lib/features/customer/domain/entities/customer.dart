import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.note,
    this.totalSpent = 0.0,
    this.visitCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? note;
  final double totalSpent;
  final int visitCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? note,
    double? totalSpent,
    int? visitCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      note: note ?? this.note,
      totalSpent: totalSpent ?? this.totalSpent,
      visitCount: visitCount ?? this.visitCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    note,
    totalSpent,
    visitCount,
    createdAt,
    updatedAt,
  ];
}
