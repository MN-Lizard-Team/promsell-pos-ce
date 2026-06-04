import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

const Object _unset = Object();

enum HistoryStatus { initial, loading, success, failure, voiding }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.sales = const [],
    this.from,
    this.to,
    this.errorMessage,
    this.searchQuery = '',
  });

  final HistoryStatus status;
  final List<Sale> sales;
  final DateTime? from;
  final DateTime? to;
  final String? errorMessage;
  final String searchQuery;

  List<Sale> get filteredSales {
    if (searchQuery.isEmpty) return sales;
    final q = searchQuery.toLowerCase();
    return sales.where((s) {
      final receipt = s.receiptNumber?.toLowerCase() ?? '';
      final payment = s.paymentMethod.toLowerCase();
      final amount = s.totalAmount.toStringAsFixed(2);
      return receipt.contains(q) || payment.contains(q) || amount.contains(q);
    }).toList();
  }

  HistoryState copyWith({
    HistoryStatus? status,
    List<Sale>? sales,
    Object? from = _unset,
    Object? to = _unset,
    Object? errorMessage = _unset,
    String? searchQuery,
  }) => HistoryState(
    status: status ?? this.status,
    sales: sales ?? this.sales,
    from: identical(from, _unset) ? this.from : from as DateTime?,
    to: identical(to, _unset) ? this.to : to as DateTime?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    searchQuery: searchQuery ?? this.searchQuery,
  );

  @override
  List<Object?> get props => [
    status,
    sales,
    from,
    to,
    errorMessage,
    searchQuery,
  ];
}
