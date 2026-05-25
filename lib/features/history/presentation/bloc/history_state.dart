import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

const Object _unset = Object();

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.sales = const [],
    this.from,
    this.to,
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<Sale> sales;
  final DateTime? from;
  final DateTime? to;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<Sale>? sales,
    Object? from = _unset,
    Object? to = _unset,
    Object? errorMessage = _unset,
  }) =>
      HistoryState(
        status: status ?? this.status,
        sales: sales ?? this.sales,
        from: identical(from, _unset) ? this.from : from as DateTime?,
        to: identical(to, _unset) ? this.to : to as DateTime?,
        errorMessage: identical(errorMessage, _unset)
            ? this.errorMessage
            : errorMessage as String?,
      );

  @override
  List<Object?> get props => [status, sales, from, to, errorMessage];
}
