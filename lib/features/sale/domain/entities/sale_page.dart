import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

/// A single page of sales from a cursor-paginated history query.
///
/// Cursor = `(createdAt, id)` ordered DESC. Items and payments are hydrated
/// only for the sales in [sales] — not the entire date range — so memory is
/// bounded by [pageSize], not by the report window.
@immutable
class SalePage extends Equatable {
  const SalePage({
    required this.sales,
    required this.nextCursor,
    required this.totalCount,
  });

  final List<Sale> sales;
  final SaleCursor? nextCursor;
  final int totalCount;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [sales, nextCursor, totalCount];
}

/// Cursor position for sale history pagination (createdAt DESC, id DESC).
@immutable
class SaleCursor extends Equatable {
  const SaleCursor({required this.createdAt, required this.id});

  final DateTime createdAt;
  final String id;

  @override
  List<Object?> get props => [createdAt, id];
}
