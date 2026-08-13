import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/stock_status_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/inventory_log_helper.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class StockTab extends StatelessWidget {
  const StockTab({
    super.key,
    required this.product,
    required this.currency,
    required this.watchInventoryLogs,
    this.onAdjustStock,
    this.onViewFullHistory,
  });

  final Product product;
  final String currency;
  final WatchInventoryLogs watchInventoryLogs;

  /// Same inventory adjust sheet as product form edit (logged movement).
  final VoidCallback? onAdjustStock;

  /// Jump to History tab on product preview (optional).
  final VoidCallback? onViewFullHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cs = theme.colorScheme;
    final stockValue = product.cost * product.stock;
    final saleValue = product.price * product.stock;
    final potentialProfit = (product.price - product.cost) * product.stock;
    final dividerColor = cs.outlineVariant.withValues(alpha: 0.3);
    final threshold = _threshold(context);
    final status = resolveStockStatus(
      trackStock: product.trackStock,
      stock: product.stock,
      lowStockThreshold: threshold,
      l10n: l10n,
      cs: cs,
    );
    final unit = (product.unit ?? '').trim();
    final unitLabel = unit.isEmpty ? l10n.quantityLabel : unit;
    final qtyText = CurrencyFormatter.formatGroupedInt(product.stock);

    return ListView(
      padding: productPreviewTabPadding,
      children: [
        PreviewCard(
          title: l10n.tabStock,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!product.trackStock)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n.stockTrackingDisabled,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                Text(
                  l10n.quantityLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: qtyText,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' $unitLabel',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (onAdjustStock != null)
                      OutlinedButton.icon(
                        key: const ValueKey('product-preview-adjust-stock'),
                        onPressed: onAdjustStock,
                        icon: const Icon(TablerIcons.adjustments, size: 18),
                        label: Text(l10n.adjustStock),
                      ),
                  ],
                ),
                if (onAdjustStock != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        TablerIcons.infoCircle,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.editStockAdjustHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                _PreviewStockStatusBanner(status: status),
              ],
            ],
          ),
        ),
        if (product.trackStock) ...[
          const SizedBox(height: 16),
          PreviewCard(
            title: l10n.productPreviewStockValue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.cost > Money.zero)
                  InfoListItem(
                    icon: TablerIcons.wallet,
                    label: l10n.productPreviewStockValue,
                    value: MoneyText(
                      value: stockValue.value,
                      currency: currency,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (product.cost > Money.zero)
                  Divider(height: 1, color: dividerColor),
                InfoListItem(
                  icon: TablerIcons.receipt,
                  label: l10n.productPreviewStockValueSale,
                  value: MoneyText(
                    value: saleValue.value,
                    currency: currency,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (product.cost > Money.zero) ...[
                  Divider(height: 1, color: dividerColor),
                  InfoListItem(
                    icon: TablerIcons.trendingUp,
                    label: l10n.productPreviewPotentialProfit,
                    value: MoneyText(
                      value: potentialProfit.value,
                      currency: currency,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    valueColor: theme.colorScheme.tertiary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StockSummarySection(
            productId: product.id,
            watchInventoryLogs: watchInventoryLogs,
            onViewFullHistory: onViewFullHistory,
          ),
        ],
      ],
    );
  }

  int _threshold(BuildContext context) {
    try {
      return context.watch<SettingsCubit>().state.settings.lowStockThreshold;
    } catch (_) {
      return 5;
    }
  }
}

class _PreviewStockStatusBanner extends StatelessWidget {
  const _PreviewStockStatusBanner({required this.status});

  final ResolvedStockStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Material(
      color: status.containerColor,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: status.color.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Icon(status.icon, size: 20, color: status.onContainerColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.productPreviewStatus}: ${status.label}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: status.onContainerColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockSummarySection extends StatelessWidget {
  const _StockSummarySection({
    required this.productId,
    required this.watchInventoryLogs,
    this.onViewFullHistory,
  });

  final String productId;
  final WatchInventoryLogs watchInventoryLogs;
  final VoidCallback? onViewFullHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.yMMMd(locale);
    final timeFormat = DateFormat.Hm(locale);
    final dividerColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.3,
    );

    return StreamBuilder<List<InventoryLog>>(
      stream: watchInventoryLogs(productId: productId),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        final totalSold = logs
            .where((l) => l.type == 'SALE')
            .fold(0, (sum, l) => sum + l.qtyChange.abs());
        final totalIn = logs
            .where(
              (l) => l.type == 'ADJUSTMENT_IN' || l.type == 'VOID_REVERSAL',
            )
            .fold(0, (sum, l) => sum + l.qtyChange);
        final totalOut = logs
            .where((l) => l.type == 'ADJUSTMENT_OUT')
            .fold(0, (sum, l) => sum + l.qtyChange.abs());
        final lastLog = logs.isNotEmpty ? logs.first : null;
        final recentLogs = logs.take(3).toList();

        return PreviewCard(
          title: l10n.productPreviewRecentMoves,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoListItem(
                icon: TablerIcons.shoppingCart,
                label: l10n.productPreviewTotalSold,
                value: Text(
                  '$totalSold ${l10n.quantityLabel}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                valueColor: theme.colorScheme.error,
              ),
              Divider(height: 1, color: dividerColor),
              InfoListItem(
                icon: TablerIcons.circlePlus,
                label: l10n.productPreviewTotalIn,
                value: Text(
                  '$totalIn ${l10n.quantityLabel}',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                valueColor: theme.colorScheme.primary,
              ),
              Divider(height: 1, color: dividerColor),
              InfoListItem(
                icon: TablerIcons.circleMinus,
                label: l10n.productPreviewTotalOut,
                value: Text('$totalOut ${l10n.quantityLabel}'),
              ),
              if (lastLog != null) ...[
                Divider(height: 1, color: dividerColor),
                InfoListItem(
                  icon: TablerIcons.refresh,
                  label: l10n.productPreviewLastUpdate,
                  value: Text(
                    '${dateFormat.format(lastLog.createdAt)} ${timeFormat.format(lastLog.createdAt)}',
                  ),
                ),
              ],
              if (recentLogs.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: dividerColor),
                const SizedBox(height: 12),
                Text(
                  l10n.productPreviewRecentMoves,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...recentLogs.map((log) => _RecentMoveItem(log: log)),
              ],
              if (onViewFullHistory != null && logs.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onViewFullHistory,
                    child: Text(l10n.productHistoryViewAll),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RecentMoveItem extends StatelessWidget {
  const _RecentMoveItem({required this.log});

  final InventoryLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final timeFormat = DateFormat.Hm(locale);
    final isPositive = log.isPositive;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            InventoryLogHelper.iconForType(log.type),
            size: 16,
            color: isPositive
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            InventoryLogHelper.labelForType(l10n, log.type),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            '${isPositive ? '+' : ''}${log.qtyChange}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isPositive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeFormat.format(log.createdAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
