import 'package:equatable/equatable.dart';

class InventoryLog extends Equatable {
  const InventoryLog({
    required this.id,
    required this.productId,
    required this.type,
    required this.qtyChange,
    required this.balanceAfter,
    this.reason,
    this.refSaleId,
    required this.createdAt,
    this.deviceId,
    this.updatedAt,
    this.deletedAt,
    this.version = 1,
  });

  final String id;
  final String productId;
  final String type;
  final int qtyChange;
  final int balanceAfter;
  final String? reason;
  final String? refSaleId;
  final DateTime createdAt;
  final String? deviceId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int version;

  bool get isPositive => qtyChange >= 0;

  @override
  List<Object?> get props => [
    id,
    productId,
    type,
    qtyChange,
    balanceAfter,
    reason,
    refSaleId,
    createdAt,
    deviceId,
    updatedAt,
    deletedAt,
    version,
  ];
}
