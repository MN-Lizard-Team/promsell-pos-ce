import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

/// One tender line on a completed (or in-progress checkout) sale.
///
/// Shared domain entity — used by sale, report, history, receipt, and home
/// features. Lives in `lib/shared/domain/` to avoid cross-feature domain
/// coupling.
class SalePayment extends Equatable {
  const SalePayment({
    required this.method,
    required this.amount,
    this.id,
    this.saleId,
    this.reference,
    this.sendingBankCode,
    this.sortOrder = 0,
  });

  final String? id;
  final String? saleId;
  final String method;
  final Money amount;
  final String? reference;
  final String? sendingBankCode;
  final int sortOrder;

  @override
  List<Object?> get props => [
    id,
    saleId,
    method,
    amount,
    reference,
    sendingBankCode,
    sortOrder,
  ];
}
