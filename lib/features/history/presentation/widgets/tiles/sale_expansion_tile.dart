import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_dialog_shell.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/widgets/tiles/sale_expansion_tile/sale_receipt_actions.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

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
    final settings = context.watch<SettingsCubit>().state.settings;
    final isVoided = sale.isVoided;

    return Opacity(
      opacity: isVoided ? 0.6 : 1.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: isVoided
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.primaryContainer,
            child: Icon(
              isVoided ? Icons.block : Icons.receipt_long_outlined,
              color: isVoided
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: MoneyText(
                  value: sale.totalAmount.value,
                  currency: settings.currency,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isVoided ? TextDecoration.lineThrough : null,
                  ),
                  color: isVoided
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
              if (isVoided)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    context.l10n.voided,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '${sale.receiptNumber ?? '#${sale.id.substring(0, 8)}'}  •  $dateFormat  •  ${formatSalePaymentSummary(context, sale, currency: settings.currency)}',
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            ...sale.items.map(
              (item) => ListTile(
                dense: true,
                title: Text(item.productName),
                subtitle: Text(
                  '${item.qty} × ${settings.currency}${item.price.value.toStringAsFixed(2)}',
                ),
                trailing: MoneyText(
                  value: item.subtotal.value,
                  currency: settings.currency,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (sale.payments.length > 1) ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              ...formatSalePaymentLines(
                context,
                sale,
                currency: settings.currency,
              ).map(
                (line) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(line, style: theme.textTheme.bodySmall),
                  ),
                ),
              ),
            ],
            if (sale.vatMode != 'NONE') ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.receiptLabelSubtotal,
                          style: theme.textTheme.bodySmall,
                        ),
                        MoneyText(
                          value: sale.subtotalAmount.value,
                          currency: settings.currency,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${context.l10n.receiptLabelVat} ${sale.vatRate.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall,
                        ),
                        MoneyText(
                          value: sale.vatAmount.value,
                          currency: settings.currency,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (isVoided) ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sale.voidedAt != null)
                      Text(
                        context.l10n.voidedAtLabel(
                          DateFormat(
                            '${settings.dateFormat} HH:mm',
                            settings.locale.languageCode,
                          ).format(sale.voidedAt!),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (sale.voidReason != null &&
                        sale.voidReason!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${context.l10n.voidReason}: ${sale.voidReason!.trim()}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (sale.note != null && sale.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  context.l10n.noteLabel(sale.note!),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                if (!isVoided)
                  isVoiding
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : TextButton.icon(
                          icon: Icon(
                            Icons.block,
                            color: theme.colorScheme.error,
                          ),
                          label: Text(
                            context.l10n.voidSale,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          onPressed: voidBusy
                              ? null
                              : () => VoidSaleDialog.show(context, sale),
                        ),
                TextButton.icon(
                  icon: const Icon(Icons.print_outlined),
                  label: Text(context.l10n.printReceipt),
                  onPressed: () =>
                      SaleReceiptActions.printReceipt(context, sale, settings),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: Text(context.l10n.shareReceipt),
                  onPressed: () =>
                      SaleReceiptActions.shareReceipt(context, sale, settings),
                ),
              ],
            ),
          ],
        ),
      ),
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
      barrierDismissible: false,
      builder: (dialogCtx) {
        String? reasonError;
        return StatefulBuilder(
          builder: (context, setDialogState) => AppDialogShell(
            title: l10n.voidSale,
            message: l10n.voidSaleConfirm,
            detail: sale.receiptNumber ?? '#${sale.id.substring(0, 8)}',
            icon: Icons.block,
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
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textOnPrimary,
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
