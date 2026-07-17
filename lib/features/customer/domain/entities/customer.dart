import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

const Object _unset = Object();

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.note,
    this.totalSpent = Money.zero,
    this.visitCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? note;
  final Money totalSpent;
  final int visitCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// [phone]/[email]/[note] use [_unset] so callers can clear with `null`.
  Customer copyWith({
    String? id,
    String? name,
    Object? phone = _unset,
    Object? email = _unset,
    Object? note = _unset,
    Money? totalSpent,
    int? visitCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: identical(phone, _unset) ? this.phone : phone as String?,
      email: identical(email, _unset) ? this.email : email as String?,
      note: identical(note, _unset) ? this.note : note as String?,
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
