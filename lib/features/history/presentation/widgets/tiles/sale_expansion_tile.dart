import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_dialog_shell.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/widgets/tiles/sale_expansion_tile/sale_receipt_actions.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class SaleExpansionTile extends StatelessWidget {
  const SaleExpansionTile({
    super.key,
    required this.sale,
    required this.dateFormat,
    this.isVoiding = false,
    this.voidBusy = false,
  });

  final Sale sale;
  final String dateFormat;

  /// This sale is currently being voided.
  final bool isVoiding;

  /// Any void is in flight (disable other void buttons).
  final bool voidBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = context.watch<SettingsCubit>().state.settings;
    final reportTheme =
        theme.extension<ReportThemeExtension>() ?? ReportThemeExtension.light;
    final isVoided = sale.isVoided;
    final dayVoidBlocked = SalesDayLock.isVoidBlocked(
      dailyCloseLock: settings.dailyCloseLock,
      lastClosedDate: settings.lastClosedDate,
      saleCreatedAt: sale.createdAt,
    );
    final l10n = context.l10n;
    final receiptLabel = sale.receiptNumber ?? '#${sale.id.substring(0, 8)}';
    final semanticLabel = isVoided
        ? '$receiptLabel, ${l10n.voided}, ${settings.currency}${sale.totalAmount.value.toStringAsFixed(2)}'
        : '$receiptLabel, ${localizePaymentMethod(context, sale.primaryPaymentMethod)}, ${settings.currency}${sale.totalAmount.value.toStringAsFixed(2)}, ${l10n.itemsCount(sale.items.length)}';

    final accentColor = isVoided ? scheme.error : scheme.primary;
    final accentBg = isVoided ? scheme.errorContainer : scheme.primaryContainer;

    return Semantics(
      container: true,
      label: semanticLabel,
      button: true,
      hint: l10n.tapToExpandHint,
      child: Opacity(
        opacity: isVoided ? 0.75 : 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(reportTheme.cardRadius),
            boxShadow: reportTheme.cardShadow,
          ),
          child: Card(
            elevation: 0,
            color: scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(reportTheme.cardRadius),
              side: BorderSide(
                color: isVoiding
                    ? scheme.primary.withValues(alpha: 0.6)
                    : isVoided
                    ? scheme.error.withValues(alpha: 0.3)
                    : scheme.outlineVariant.withValues(alpha: 0.5),
                width: isVoiding ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              onExpansionChanged: (_) => HapticFeedback.lightImpact(),
              tilePadding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              leading: ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(
                      reportTheme.controlRadius,
                    ),
                  ),
                  child: Icon(
                    isVoided ? TablerIcons.ban : TablerIcons.receipt,
                    color: accentColor,
                    size: 22,
                  ),
                ),
              ),
              title: Text(
                receiptLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'NotoSansThai',
                  letterSpacing: -0.1,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '$dateFormat  •  ${l10n.itemsCount(sale.items.length)}  •  ${localizePaymentMethod(context, sale.primaryPaymentMethod)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFamily: 'NotoSansThai',
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isVoided)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.voided,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'NotoSansThai',
                        ),
                      ),
                    ),
                  MoneyText(
                    value: sale.totalAmount.value,
                    currency: settings.currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'NotoSansThai',
                      decoration: isVoided ? TextDecoration.lineThrough : null,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              children: [
                _SaleItemsSection(sale: sale, currency: settings.currency),
                if (sale.discountAmount.value > 0)
                  _SaleDiscountSection(sale: sale, currency: settings.currency),
                if (sale.payments.isNotEmpty)
                  _SalePaymentsSection(sale: sale, currency: settings.currency),
                if (sale.vatMode != 'NONE')
                  _SaleVatSection(sale: sale, currency: settings.currency),
                if (isVoided)
                  _SaleVoidInfoSection(sale: sale, settings: settings),
                if (sale.note != null && sale.note!.isNotEmpty)
                  _SaleNoteSection(sale: sale),
                const SizedBox(height: 8),
                _SaleActionsBar(
                  sale: sale,
                  isVoided: isVoided,
                  isVoiding: isVoiding,
                  voidBusy: voidBusy,
                  dayVoidBlocked: dayVoidBlocked,
                  settings: settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaleItemsSection extends StatelessWidget {
  const _SaleItemsSection({required this.sale, required this.currency});

  final Sale sale;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    return Column(
      children: [
        for (final item in sale.items) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'NotoSansThai',
                        ),
                      ),
                      if (item.selectedOptions.any(
                        (o) => o.optionName.isNotEmpty,
                      )) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.selectedOptions
                              .map((o) => o.optionName)
                              .where((name) => name.isNotEmpty)
                              .join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFamily: 'NotoSansThai',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        '${item.qty} × $currency${item.price.value.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFamily: 'NotoSansThai',
                        ),
                      ),
                      if (item.discountAmount.value > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.discountSectionLabel}: -$currency${item.discountAmount.value.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                            fontFamily: 'NotoSansThai',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                MoneyText(
                  value: item.subtotal.value,
                  currency: currency,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'NotoSansThai',
                  ),
                ),
              ],
            ),
          ),
          if (sale.items.length > 1 && item != sale.items.last)
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
        ],
      ],
    );
  }
}

class _SaleDiscountSection extends StatelessWidget {
  const _SaleDiscountSection({required this.sale, required this.currency});

  final Sale sale;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    return Column(
      children: [
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sale.promotionDiscountAmount.value > 0
                  ? l10n.receiptLabelPromotionDiscount
                  : l10n.cartDiscount,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.error,
                fontFamily: 'NotoSansThai',
              ),
            ),
            MoneyText(
              value: sale.discountAmount.value,
              currency: currency,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansThai',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SalePaymentsSection extends StatelessWidget {
  const _SalePaymentsSection({required this.sale, required this.currency});

  final Sale sale;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 8),
        ...formatSalePaymentLines(context, sale, currency: currency).map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'NotoSansThai',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaleVatSection extends StatelessWidget {
  const _SaleVatSection({required this.sale, required this.currency});

  final Sale sale;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
        _VatRow(
          label: context.l10n.receiptLabelSubtotal,
          value: sale.subtotalAmount.value,
          currency: currency,
        ),
        const SizedBox(height: 4),
        _VatRow(
          label:
              '${context.l10n.receiptLabelVat} ${sale.vatRate.toStringAsFixed(0)}%',
          value: sale.vatAmount.value,
          currency: currency,
        ),
      ],
    );
  }
}

class _VatRow extends StatelessWidget {
  const _VatRow({
    required this.label,
    required this.value,
    required this.currency,
  });

  final String label;
  final double value;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontFamily: 'NotoSansThai',
          ),
        ),
        MoneyText(
          value: value,
          currency: currency,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'NotoSansThai',
          ),
        ),
      ],
    );
  }
}

class _SaleVoidInfoSection extends StatelessWidget {
  const _SaleVoidInfoSection({required this.sale, required this.settings});

  final Sale sale;
  final dynamic settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: scheme.error.withValues(alpha: 0.2)),
        const SizedBox(height: 8),
        if (sale.voidedAt != null)
          Text(
            context.l10n.voidedAtLabel(
              DateFormat(
                '${settings.dateFormat} HH:mm',
                settings.localeCode,
              ).format(sale.voidedAt!),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w600,
              fontFamily: 'NotoSansThai',
            ),
          ),
        if (sale.voidReason != null && sale.voidReason!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${context.l10n.voidReason}: ${sale.voidReason!.trim()}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontFamily: 'NotoSansThai',
            ),
          ),
        ],
      ],
    );
  }
}

class _SaleNoteSection extends StatelessWidget {
  const _SaleNoteSection({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 8),
        Text(
          context.l10n.noteLabel(sale.note!),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontFamily: 'NotoSansThai',
          ),
        ),
      ],
    );
  }
}

class _SaleActionsBar extends StatelessWidget {
  const _SaleActionsBar({
    required this.sale,
    required this.isVoided,
    required this.isVoiding,
    required this.voidBusy,
    required this.dayVoidBlocked,
    required this.settings,
  });

  final Sale sale;
  final bool isVoided;
  final bool isVoiding;
  final bool voidBusy;
  final bool dayVoidBlocked;
  final dynamic settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return OverflowBar(
      alignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        if (!isVoided)
          isVoiding
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : FilledButton.tonalIcon(
                  key: const Key('test_void_button'),
                  icon: const Icon(TablerIcons.ban, size: 18),
                  label: Text(context.l10n.voidSale),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.errorContainer,
                    foregroundColor: scheme.error,
                    minimumSize: const Size(48, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NotoSansThai',
                    ),
                  ),
                  onPressed: (voidBusy || dayVoidBlocked)
                      ? null
                      : () => VoidSaleDialog.show(context, sale),
                ),
        FilledButton.tonalIcon(
          icon: const Icon(TablerIcons.printer, size: 18),
          label: Text(context.l10n.reprintReceipt),
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'NotoSansThai',
            ),
          ),
          onPressed: () =>
              SaleReceiptActions.printReceipt(context, sale, settings),
        ),
        FilledButton.tonalIcon(
          icon: const Icon(TablerIcons.share, size: 18),
          label: Text(context.l10n.shareReceiptCopy),
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'NotoSansThai',
            ),
          ),
          onPressed: () =>
              SaleReceiptActions.shareReceipt(context, sale, settings),
        ),
      ],
    );
  }
}

class VoidSaleDialog {
  VoidSaleDialog._();

  static Future<void> show(BuildContext context, Sale sale) async {
    final reasonController = TextEditingController();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const actionRadius = BorderRadius.all(Radius.circular(12));

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        String? reasonError;
        return StatefulBuilder(
          builder: (context, setDialogState) => AppDialogShell(
            title: l10n.voidSale,
            message: l10n.voidSaleConfirm,
            detail: sale.receiptNumber ?? '#${sale.id.substring(0, 8)}',
            icon: TablerIcons.ban,
            tone: DialogTone.destructive,
            body: TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.voidReason,
                hintText: l10n.voidReasonHint,
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: reasonError,
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (reasonError != null) {
                  setDialogState(() => reasonError = null);
                }
              },
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? cs.surfaceContainerHighest
                      : const Color(0xFFF1F5F9),
                  foregroundColor: cs.onSurface,
                  elevation: 0,
                  minimumSize: const Size(48, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: actionRadius,
                  ),
                ),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) {
                    setDialogState(() => reasonError = l10n.voidReasonRequired);
                    return;
                  }
                  Navigator.pop(dialogCtx, true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                  elevation: 0,
                  minimumSize: const Size(48, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: actionRadius,
                  ),
                ),
                child: Text(l10n.voidSale),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final reason = reasonController.text.trim();
      if (reason.isEmpty) {
        reasonController.dispose();
        return;
      }
      final unlocked = await ensureAppUnlocked(
        context,
        title: context.l10n.appLockConfirmVoid,
      );
      if (!unlocked || !context.mounted) {
        reasonController.dispose();
        return;
      }
      context.read<HistoryBloc>().add(
        SaleVoidRequested(saleId: sale.id, reason: reason),
      );
    }
    reasonController.dispose();
  }
}
