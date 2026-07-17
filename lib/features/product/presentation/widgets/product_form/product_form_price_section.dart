import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/stable_listenable_builder.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_pricing_insights.dart';

/// Price-tab widgets extracted from [ProductFormView] (insights, markup, delta).

/// Live pricing insights: profit, margin, markup, loss warning, stock estimate.
class ProductFormPriceInsights extends StatelessWidget {
  const ProductFormPriceInsights({
    super.key,
    required this.priceCtrl,
    required this.costCtrl,
    required this.stockCtrl,
    required this.trackStock,
    required this.currency,
  });

  final TextEditingController priceCtrl;
  final TextEditingController costCtrl;
  final TextEditingController stockCtrl;
  final bool trackStock;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return StableListenableBuilder(
      listenables: [priceCtrl, costCtrl, stockCtrl],
      builder: (context, _) {
        final insights = ProductPricingInsights.fromText(
          priceText: priceCtrl.text,
          costText: costCtrl.text,
        );
        final stock = int.tryParse(stockCtrl.text) ?? 0;
        final price = insights.price;
        final profit = insights.profit;
        final muted = cs.onSurfaceVariant;
        final profitColor = !insights.hasCost
            ? muted
            : (profit != null && profit.isNegative ? cs.error : cs.tertiary);

        final showEmptyCostHint = !insights.hasCost && price > Money.zero;
        final showStockEstimate = trackStock && stock > 0 && price > Money.zero;

        Money? estRevenue;
        Money? estProfit;
        if (showStockEstimate) {
          estRevenue = price * stock;
          if (profit != null) {
            estProfit = profit * stock;
          }
        }

        String moneyOrDash(Money? m) {
          if (m == null) return '—';
          return CurrencyFormatter.formatGroupedWithSymbol(m.value, currency);
        }

        String pctOrDash(double? p) {
          if (p == null) return '—';
          return '${p.toStringAsFixed(1)} %';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ProductFormMiniStat(
                    label: l10n.profit,
                    value: moneyOrDash(profit),
                    color: profitColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProductFormMiniStat(
                    label: l10n.profitMargin,
                    value: pctOrDash(insights.marginPct),
                    color: profitColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProductFormMiniStat(
                    label: l10n.productPreviewMarkup,
                    value: pctOrDash(insights.markupPct),
                    color: profitColor,
                  ),
                ),
              ],
            ),
            if (showEmptyCostHint) ...[
              const SizedBox(height: 10),
              Container(
                key: const ValueKey('product-form-cost-empty-hint'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.productFormCostEmptyHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (insights.isLoss) ...[
              const SizedBox(height: 10),
              Container(
                key: const ValueKey('product-form-cost-warning'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.error.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: cs.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.costExceedsPriceWarning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showStockEstimate) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.priceStockEstimateTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ProductFormMiniStat(
                            label: l10n.priceStockEstimateRevenue,
                            value: moneyOrDash(estRevenue),
                            color: cs.primary,
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ProductFormMiniStat(
                            label: l10n.priceStockEstimateProfit,
                            value: moneyOrDash(estProfit),
                            color: estProfit == null
                                ? muted
                                : (estProfit.isNegative
                                      ? cs.error
                                      : cs.tertiary),
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Markup % presets that write selling price from cost (explicit apply only).
class ProductFormMarkupPresetChips extends StatelessWidget {
  const ProductFormMarkupPresetChips({
    super.key,
    required this.priceCtrl,
    required this.costCtrl,
  });

  final TextEditingController priceCtrl;
  final TextEditingController costCtrl;

  static const _presets = [20.0, 30.0, 50.0, 100.0];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return StableListenableBuilder(
      listenables: [priceCtrl, costCtrl],
      builder: (context, _) {
        final cost = parseOptionalCostText(costCtrl.text);
        final enabled = cost != null && !cost.isNegative;
        final insights = ProductPricingInsights.fromText(
          priceText: priceCtrl.text,
          costText: costCtrl.text,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.productFormMarkupFromCost,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              key: const ValueKey('product-form-markup-presets'),
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _presets)
                  ChoiceChip(
                    key: ValueKey('product-form-markup-chip-${p.toInt()}'),
                    label: Text(
                      '+${p.toInt()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _isSelected(insights, p) && enabled
                            ? cs.onPrimary
                            : cs.onSurface,
                      ),
                    ),
                    selected: enabled && _isSelected(insights, p),
                    selectedColor: cs.primary,
                    backgroundColor: cs.surface,
                    side: BorderSide(
                      color: enabled && _isSelected(insights, p)
                          ? cs.primary
                          : cs.outline,
                    ),
                    showCheckmark: false,
                    onSelected: enabled
                        ? (_) {
                            final next = ProductPricingInsights.priceFromMarkup(
                              cost,
                              p,
                            );
                            priceCtrl.text = next.value.toStringAsFixed(2);
                            priceCtrl.selection = TextSelection.collapsed(
                              offset: priceCtrl.text.length,
                            );
                          }
                        : null,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  bool _isSelected(ProductPricingInsights insights, double preset) {
    final m = insights.markupPct;
    if (m == null) return false;
    return (m - preset).abs() < 0.5;
  }
}

/// Edit-only: show baseline → live when price/cost satang differs.
class ProductFormPriceDeltaStrip extends StatelessWidget {
  const ProductFormPriceDeltaStrip({
    super.key,
    required this.priceCtrl,
    required this.costCtrl,
    required this.baselinePrice,
    required this.baselineCost,
    required this.currency,
  });

  final TextEditingController priceCtrl;
  final TextEditingController costCtrl;
  final Money? baselinePrice;
  final Money? baselineCost;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (baselinePrice == null && baselineCost == null) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return StableListenableBuilder(
      listenables: [priceCtrl, costCtrl],
      builder: (context, _) {
        final livePrice = parsePriceText(priceCtrl.text);
        final liveCost = parseOptionalCostText(costCtrl.text);

        final rows = <Widget>[];

        if (baselinePrice != null && livePrice != baselinePrice) {
          rows.add(
            _deltaRow(
              context,
              label: l10n.sellingPrice,
              from: baselinePrice!,
              to: livePrice,
            ),
          );
        }

        if (baselineCost != null &&
            liveCost != null &&
            liveCost != baselineCost) {
          if (rows.isNotEmpty) rows.add(const SizedBox(height: 4));
          rows.add(
            _deltaRow(
              context,
              label: l10n.productPreviewCost,
              from: baselineCost!,
              to: liveCost,
            ),
          );
        }

        if (rows.isEmpty) return const SizedBox.shrink();

        return Padding(
          key: const ValueKey('product-form-price-delta'),
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
          ),
        );
      },
    );
  }

  Widget _deltaRow(
    BuildContext context, {
    required String label,
    required Money from,
    required Money to,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fromText = CurrencyFormatter.formatGroupedWithSymbol(
      from.value,
      currency,
    );
    final toText = CurrencyFormatter.formatGroupedWithSymbol(
      to.value,
      currency,
    );
    final delta = to.subtractUnclamped(from);
    final deltaText = CurrencyFormatter.formatGroupedWithSymbol(
      delta.value,
      currency,
    );
    final sign = delta.isNegative
        ? ''
        : delta.isZero
        ? ''
        : '+';
    final deltaColor = delta.isNegative
        ? cs.error
        : delta.isZero
        ? cs.onSurfaceVariant
        : cs.tertiary;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            l10n.productFormPriceChanged(fromText, toText),
            textAlign: TextAlign.end,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($sign$deltaText)',
          style: theme.textTheme.labelSmall?.copyWith(
            color: deltaColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ProductFormMiniStat extends StatelessWidget {
  const ProductFormMiniStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: compact ? 10 : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: compact ? 13 : null,
            ),
          ),
        ],
      ),
    );
  }
}
