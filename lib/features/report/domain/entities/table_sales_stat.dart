import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Per-table sales aggregate for one report period.
///
/// Produced by a SQL `GROUP BY table_id` over non-voided sales with
/// satang-exact revenue. The datasource yields raw rows whose [tableId]
/// mirrors the nullable `sales.table_id` column; the repository folds NULLs
/// into the explicit [noTableBucket] so UI layers never receive a null id.
@immutable
class TableSalesStat extends Equatable {
  const TableSalesStat({
    required this.tableId,
    required this.orderCount,
    required this.revenueSatang,
    required this.lastSaleAt,
  });

  /// Bucket key substituted by the repository when `sales.table_id` is NULL.
  /// Never a real table id and never rendered raw — display surfaces map it
  /// to the localized "no table" label.
  static const String noTableBucket = '';

  /// Table id, or [noTableBucket] when the bucket aggregates table-less
  /// sales.
  final String tableId;

  /// Completed (non-voided) order count inside the bucket.
  final int orderCount;

  /// Completed revenue in satang — exact, no double rounding.
  final int revenueSatang;

  /// Newest completed sale time inside the bucket.
  final DateTime lastSaleAt;

  /// True when this bucket aggregates sales without a table link.
  bool get isNoTable => tableId == noTableBucket;

  /// Baht value for display ([MoneyText] / share bars).
  double get revenue => revenueSatang / 100.0;

  @override
  List<Object?> get props => [tableId, orderCount, revenueSatang, lastSaleAt];
}
