import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/inventory_log_helper.dart';

/// Shared inventory movement row for product History tab and InventoryLog page.
class InventoryLogRow extends StatelessWidget {
  const InventoryLogRow({super.key, required this.log});

  final InventoryLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.yMMMd(locale);
    final timeFormat = DateFormat.Hm(locale);
    final isPositive = log.isPositive;
    final toneColor = isPositive ? cs.primary : cs.error;
    final reason = InventoryLogHelper.localizeReason(l10n, log.reason);
    final showSaleRef =
        (log.type == InventoryLogHelper.typeSale ||
            log.type == InventoryLogHelper.typeVoidReversal) &&
        log.refSaleId != null &&
        log.refSaleId!.isNotEmpty;
    final qty = CurrencyFormatter.formatQuantityCompact(log.qtyChange.abs());
    final balance = CurrencyFormatter.formatQuantityCompact(log.balanceAfter);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPositive ? cs.primaryContainer : cs.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              InventoryLogHelper.iconForType(log.type),
              color: toneColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  InventoryLogHelper.labelForType(l10n, log.type),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (reason != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    reason,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (showSaleRef) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.invLogSaleRef(
                      InventoryLogHelper.shortSaleRef(log.refSaleId!),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(log.createdAt)} ${timeFormat.format(log.createdAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}$qty',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: toneColor,
                ),
              ),
              Text(
                '→ $balance',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
