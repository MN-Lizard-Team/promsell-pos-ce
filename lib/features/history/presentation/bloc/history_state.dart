import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

const Object _unset = Object();

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.sales = const [],
    this.from,
    this.to,
    this.errorMessage,
    this.searchQuery = '',
    this.voidingSaleId,
  });

  final HistoryStatus status;
  final List<Sale> sales;
  final DateTime? from;
  final DateTime? to;
  final String? errorMessage;
  final String searchQuery;

  /// When non-null, a void is in flight for this sale (list stays visible).
  final String? voidingSaleId;

  List<Sale> get filteredSales {
    if (searchQuery.isEmpty) return sales;
    final q = searchQuery.toLowerCase();
    return sales.where((s) {
      final receipt = s.receiptNumber?.toLowerCase() ?? '';
      final payment = s.paymentMethod.toLowerCase();
      final amount = s.totalAmount.value.toStringAsFixed(2);
      // H16: Also search in customer ID, product names, notes, and void reason.
      final customerId = s.customerId?.toLowerCase() ?? '';
      final note = s.note?.toLowerCase() ?? '';
      final voidReason = s.voidReason?.toLowerCase() ?? '';
      final productNames = s.items
          .map((i) => i.productName.toLowerCase())
          .join(' ');
      return receipt.contains(q) ||
          payment.contains(q) ||
          amount.contains(q) ||
          customerId.contains(q) ||
          note.contains(q) ||
          voidReason.contains(q) ||
          productNames.contains(q);
    }).toList();
  }

  HistoryState copyWith({
    HistoryStatus? status,
    List<Sale>? sales,
    Object? from = _unset,
    Object? to = _unset,
    Object? errorMessage = _unset,
    String? searchQuery,
    Object? voidingSaleId = _unset,
  }) => HistoryState(
    status: status ?? this.status,
    sales: sales ?? this.sales,
    from: identical(from, _unset) ? this.from : from as DateTime?,
    to: identical(to, _unset) ? this.to : to as DateTime?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    searchQuery: searchQuery ?? this.searchQuery,
    voidingSaleId: identical(voidingSaleId, _unset)
        ? this.voidingSaleId
        : voidingSaleId as String?,
  );

  @override
  List<Object?> get props => [
    status,
    sales,
    from,
    to,
    errorMessage,
    searchQuery,
    voidingSaleId,
  ];
}
