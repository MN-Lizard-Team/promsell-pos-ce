import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

/// SQL-aggregated report summary for a date range, computed without
/// hydrating `List<Sale>`. Money fields are satang-SSOT (INTEGER aggregation).
///
/// Mirrors the subset of [SalesPeriodTotals] that can be derived from the
/// `sales` table alone (no item-level data). Item-derived metrics like
/// top-products and profit still require hydration via the existing path.
@immutable
class ReportSummary extends Equatable {
  const ReportSummary({
    required this.netRevenue,
    required this.voidedTotal,
    required this.salesCount,
    required this.voidCount,
    required this.vatAmount,
    required this.discountAmount,
    required this.serviceChargeAmount,
    required this.promotionDiscountAmount,
    required this.paymentBreakdown,
    required this.paymentCounts,
    required this.orderTypeBreakdown,
    required this.orderChannelBreakdown,
    required this.voidReasonBreakdown,
    required this.promotionCount,
  });

  final Money netRevenue;
  final Money voidedTotal;
  final int salesCount;
  final int voidCount;
  final Money vatAmount;
  final Money discountAmount;
  final Money serviceChargeAmount;
  final Money promotionDiscountAmount;
  final Map<String, double> paymentBreakdown;
  final Map<String, int> paymentCounts;
  final Map<String, double> orderTypeBreakdown;
  final Map<String, double> orderChannelBreakdown;
  final Map<String, int> voidReasonBreakdown;
  final int promotionCount;

  Money get grossRevenue => netRevenue + voidedTotal;

  static const empty = ReportSummary(
    netRevenue: Money.zero,
    voidedTotal: Money.zero,
    salesCount: 0,
    voidCount: 0,
    vatAmount: Money.zero,
    discountAmount: Money.zero,
    serviceChargeAmount: Money.zero,
    promotionDiscountAmount: Money.zero,
    paymentBreakdown: {},
    paymentCounts: {},
    orderTypeBreakdown: {},
    orderChannelBreakdown: {},
    voidReasonBreakdown: {},
    promotionCount: 0,
  );

  @override
  List<Object?> get props => [
    netRevenue,
    voidedTotal,
    salesCount,
    voidCount,
    vatAmount,
    discountAmount,
    serviceChargeAmount,
    promotionDiscountAmount,
    paymentBreakdown,
    paymentCounts,
    orderTypeBreakdown,
    orderChannelBreakdown,
    voidReasonBreakdown,
    promotionCount,
  ];
}
