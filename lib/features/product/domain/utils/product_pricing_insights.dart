import 'package:promsell_pos_ce/core/domain/money.dart';

/// Unit economics for a product price/cost pair.
///
/// [cost] is `null` when the cost field was left empty (distinct from cost = 0).
/// Profit uses [Money.subtractUnclamped] so losses stay negative.
class ProductPricingInsights {
  const ProductPricingInsights({
    required this.price,
    required this.cost,
    required this.hasCost,
    required this.profit,
    required this.marginPct,
    required this.markupPct,
    required this.isLoss,
  });

  final Money price;

  /// Entered cost, or `null` when the field is empty.
  final Money? cost;
  final bool hasCost;

  /// `null` when [hasCost] is false.
  final Money? profit;

  /// Gross margin % of selling price. `null` when no cost or price is zero.
  final double? marginPct;

  /// Markup % of cost. `null` when no cost or cost is zero.
  final double? markupPct;

  /// True when cost is entered, price > 0, and cost ≥ price.
  final bool isLoss;

  factory ProductPricingInsights.fromMoney({
    required Money price,
    Money? cost,
  }) {
    if (cost == null) {
      return ProductPricingInsights(
        price: price,
        cost: null,
        hasCost: false,
        profit: null,
        marginPct: null,
        markupPct: null,
        isLoss: false,
      );
    }

    final profit = price.subtractUnclamped(cost);
    final marginPct = price > Money.zero
        ? (profit.satang / price.satang) * 100.0
        : null;
    final markupPct = cost > Money.zero
        ? (profit.satang / cost.satang) * 100.0
        : null;
    final isLoss = price > Money.zero && cost >= price;

    return ProductPricingInsights(
      price: price,
      cost: cost,
      hasCost: true,
      profit: profit,
      marginPct: marginPct,
      markupPct: markupPct,
      isLoss: isLoss,
    );
  }

  /// Parse controllers: empty cost → `null` (not zero).
  factory ProductPricingInsights.fromText({
    required String priceText,
    required String costText,
  }) {
    return ProductPricingInsights.fromMoney(
      price: parsePriceText(priceText),
      cost: parseOptionalCostText(costText),
    );
  }

  /// Selling price from cost and target markup percent.
  /// e.g. cost 30 + 50% → 45.00
  static Money priceFromMarkup(Money cost, double markupPercent) {
    final factor = 1.0 + (markupPercent / 100.0);
    return Money.fromDouble(cost.value * factor);
  }
}

Money parsePriceText(String text) {
  final d = double.tryParse(text.trim());
  if (d == null) return Money.zero;
  return Money.fromDouble(d);
}

/// Empty / whitespace → `null`. Invalid parse → `null`.
Money? parseOptionalCostText(String text) {
  final t = text.trim();
  if (t.isEmpty) return null;
  final d = double.tryParse(t);
  if (d == null) return null;
  return Money.fromDouble(d);
}
