import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

/// Post-sale success header: title, optional change hero, total + method.
///
/// Money values come from **persisted** [Sale] fields only (no recalculation).
class SaleSuccessHero extends StatelessWidget {
  const SaleSuccessHero({
    super.key,
    required this.sale,
    required this.currency,
  });

  final Sale sale;
  final String currency;

  /// Show large change when cash tender left a positive change amount.
  bool get _showChange {
    final change = sale.changeAmount;
    return change != null && change.isPositive;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final receiptNo = sale.receiptNumber ?? sale.id;
    final methodLabel = formatSalePaymentSummary(context, sale);

    return Semantics(
      label: '${l.saleSuccessTitle}. ${l.saleSuccessSubtitle(receiptNo)}',
      liveRegion: true,
      child: Column(
        key: const ValueKey('sale_success_hero'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 56,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          Text(
            l.saleSuccessTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.saleSuccessSubtitle(receiptNo),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (_showChange) ...[
            const SizedBox(height: 20),
            Text(
              l.changeDue,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            MoneyText(
              value: sale.changeAmount?.value ?? 0.0,
              currency: currency,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.receiptLabelTotal,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      MoneyText(
                        value: sale.totalAmount.value,
                        currency: currency,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (sale.amountReceived != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.receiptLabelReceived,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        MoneyText(
                          value: sale.amountReceived!.value,
                          currency: currency,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          l.receiptLabelPayment,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          methodLabel,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary “Next sale” + secondary print/share row for success dialog actions.
class SaleSuccessActions extends StatelessWidget {
  const SaleSuccessActions({
    super.key,
    required this.busy,
    required this.onNextSale,
    required this.onPrint,
    required this.onShare,
  });

  final bool busy;
  final VoidCallback? onNextSale;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pos =
        Theme.of(context).extension<PosThemeExtension>() ??
        PosThemeExtension.light;

    return Column(
      key: const ValueKey('sale_success_actions'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          key: const ValueKey('sale_success_next_cta'),
          style: FilledButton.styleFrom(
            backgroundColor: pos.ctaFill,
            foregroundColor: pos.ctaOnFill,
            minimumSize: Size(double.infinity, pos.ctaMinHeight),
          ),
          onPressed: busy ? null : onNextSale,
          child: Text(
            l.nextSale,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                key: const ValueKey('sale_success_print_cta'),
                onPressed: busy ? null : onPrint,
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print_outlined),
                label: Text(l.printReceipt),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                key: const ValueKey('sale_success_share_cta'),
                onPressed: busy ? null : onShare,
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share_outlined),
                label: Text(l.shareReceipt),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
