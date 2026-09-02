import 'package:equatable/equatable.dart';

class KitchenTicketLine extends Equatable {
  const KitchenTicketLine({
    required this.lineId,
    required this.productId,
    required this.productName,
    required this.qty,
    this.note,
    this.optionsJson,
  });

  final String lineId;
  final String productId;
  final String productName;
  final int qty;
  final String? note;
  final String? optionsJson;

  @override
  List<Object?> get props => [
    lineId,
    productId,
    productName,
    qty,
    note,
    optionsJson,
  ];
}

class KitchenTicket extends Equatable {
  const KitchenTicket({
    required this.cartId,
    required this.firedAt,
    required this.lines,
    this.tableId,
    this.tableName,
  });

  final String cartId;
  final DateTime firedAt;
  final List<KitchenTicketLine> lines;
  final String? tableId;
  final String? tableName;

  @override
  List<Object?> get props => [cartId, firedAt, lines, tableId, tableName];
}
