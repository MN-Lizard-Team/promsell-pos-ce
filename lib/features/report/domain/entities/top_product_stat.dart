/// Qty-ranked top product with secondary revenue (line subtotals).
class TopProductStat {
  const TopProductStat({
    required this.displayName,
    required this.qty,
    required this.revenue,
    this.cost,
    this.profit,
    this.marginPercent,
  });

  final String displayName;
  final int qty;
  final double revenue;

  /// Total cost for this product's line items (null when no cost data).
  final double? cost;

  /// Revenue minus cost (null when no cost data).
  final double? profit;

  /// Profit margin percentage (null when no cost data or zero revenue).
  final double? marginPercent;

  /// True when this stat has cost data available.
  bool get hasCostData => cost != null;
}
