import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
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
    this.isStale = false,
    this.totalCount = 0,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final HistoryStatus status;
  final List<Sale> sales;
  final DateTime? from;
  final DateTime? to;
  final String? errorMessage;
  final String searchQuery;
  final String? voidingSaleId;
  final bool isStale;
  final int totalCount;
  final SaleCursor? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  List<Sale> get filteredSales {
    if (searchQuery.trim().isEmpty) return sales;
    final q = searchQuery.trim().toLowerCase();
    return sales.where((s) {
      final receipt = s.receiptNumber?.toLowerCase() ?? '';
      final payment = s.paymentMethod.toLowerCase();
      final paymentMethods = s.payments
          .map((p) => p.method.toLowerCase())
          .join(' ');
      final paymentReferences = s.payments
          .map((p) => p.reference?.toLowerCase() ?? '')
          .join(' ');
      final amount = s.totalAmount.value.toStringAsFixed(2);
      final customerId = s.customerId?.toLowerCase() ?? '';
      final note = s.note?.toLowerCase() ?? '';
      final voidReason = s.voidReason?.toLowerCase() ?? '';
      final productNames = s.items
          .map((i) => i.productName.toLowerCase())
          .join(' ');
      return receipt.contains(q) ||
          payment.contains(q) ||
          paymentMethods.contains(q) ||
          paymentReferences.contains(q) ||
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
    bool? isStale,
    int? totalCount,
    Object? nextCursor = _unset,
    bool? isLoadingMore,
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
    isStale: isStale ?? this.isStale,
    totalCount: totalCount ?? this.totalCount,
    nextCursor: identical(nextCursor, _unset)
        ? this.nextCursor
        : nextCursor as SaleCursor?,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
    isStale,
    totalCount,
    nextCursor,
    isLoadingMore,
  ];
}
