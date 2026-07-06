import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:shimmer/shimmer.dart';

class HomeStatsRow extends StatelessWidget {
  const HomeStatsRow({
    super.key,
    required this.revenue,
    required this.cost,
    required this.profit,
    this.isLoading = false,
  });

  final double revenue;
  final double cost;
  final double profit;
  final bool isLoading;

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
              icon: Icons.payments_outlined,
              iconColor: cs.primary,
              isLoading: isLoading,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _StatCard(
              label: l10n.homeCost,
              value: cost,
              icon: Icons.account_balance_wallet_outlined,
              iconColor: cs.secondary,
              isLoading: isLoading,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _StatCard(
              label: l10n.homeProfit,
              value: profit,
              icon: Icons.savings_outlined,
              iconColor: cs.tertiary,
              isLoading: isLoading,
              valueColor: profit < 0 ? cs.error : cs.onSurface,
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
    required this.icon,
    required this.iconColor,
    this.isLoading = false,
    this.valueColor,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final Color? valueColor;

  String _formatCompact(double v) {
    if (v.abs() >= 1000000) {
      return '฿${(v / 1000000).toStringAsFixed(1)}M';
    } else if (v.abs() >= 1000) {
      return '฿${(v / 1000).toStringAsFixed(1)}k';
    } else {
      return CurrencyFormatter.format(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      label: '$label ${_formatCompact(value)}',
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
                          _formatCompact(value),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: valueColor ?? cs.onSurface,
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
