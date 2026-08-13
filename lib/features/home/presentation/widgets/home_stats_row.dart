import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:shimmer/shimmer.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({
    super.key,
    required this.revenue,
    required this.cost,
    required this.profit,
    this.currency = '฿',
    this.isLoading = false,
    this.metricsUnknown = false,
    this.costUnknown = false,
  });

  final Money revenue;
  final Money cost;
  final Money profit;
  final String currency;
  final bool isLoading;

  /// Load failed — do not present zeros as a quiet day.
  final bool metricsUnknown;

  /// Product catalog not ready — cost/profit would be fake.
  final bool costUnknown;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.homeRevenue,
              value: revenue,
              currency: currency,
              icon: Icons.payments_outlined,
              iconColor: cs.primary,
              isLoading: isLoading,
              showPlaceholder: metricsUnknown,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _StatCard(
              label: l10n.homeCost,
              value: cost,
              currency: currency,
              icon: Icons.account_balance_wallet_outlined,
              iconColor: cs.secondary,
              isLoading: isLoading,
              showPlaceholder: metricsUnknown || costUnknown,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _StatCard(
              label: l10n.homeProfit,
              value: profit,
              currency: currency,
              icon: Icons.savings_outlined,
              iconColor: cs.tertiary,
              isLoading: isLoading,
              showPlaceholder: metricsUnknown || costUnknown,
              valueColor: profit.isNegative ? cs.error : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.currency,
    required this.icon,
    required this.iconColor,
    this.isLoading = false,
    this.showPlaceholder = false,
    this.valueColor,
  });

  final String label;
  final Money value;
  final String currency;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final bool showPlaceholder;
  final Color? valueColor;

  String _formatCompact(Money v) {
    final abs = v.value.abs();
    final sign = v.value.isNegative ? '-' : '';
    if (abs >= 1000000) {
      return '$sign$currency${(abs / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      return '$sign$currency${(abs / 1000).toStringAsFixed(1)}k';
    } else {
      return '$sign${CurrencyFormatter.formatGroupedWithSymbol(abs, currency)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final display = showPlaceholder ? '—' : _formatCompact(value);

    return Semantics(
      label: '$label $display',
      child: Card(
        elevation: 8,
        shadowColor: cs.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isLoading)
                    Shimmer.fromColors(
                      baseColor: cs.surfaceContainerHighest,
                      highlightColor: cs.surfaceContainerLow,
                      child: Container(
                        width: 60,
                        height: 22,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          display,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: showPlaceholder
                                ? cs.onSurfaceVariant
                                : (valueColor ?? cs.onSurface),
                          ),
                        ),
                      ),
                    ),
                  Icon(icon, size: 22, color: iconColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
