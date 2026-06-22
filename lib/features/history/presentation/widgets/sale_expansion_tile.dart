import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleExpansionTile extends StatelessWidget {
  const SaleExpansionTile({
    super.key,
    required this.sale,
    required this.dateFormat,
  });

  final Sale sale;
  final String dateFormat;

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
                  value: sale.totalAmount,
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
            '${sale.receiptNumber ?? '#${sale.id.substring(0, 8)}'}  •  $dateFormat  •  ${localizePaymentMethod(context, sale.paymentMethod)}',
            style: theme.textTheme.bodySmall,
          ),
          children: [
            ...sale.items.map(
              (item) => ListTile(
                dense: true,
                title: Text(item.productName),
                subtitle: Text(
                  '${item.qty} × ${settings.currency}${item.price.toStringAsFixed(2)}',
                ),
                trailing: MoneyText(
                  value: item.subtotal,
                  currency: settings.currency,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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
                          value: sale.subtotalAmount,
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
                          value: sale.vatAmount,
                          currency: settings.currency,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (sale.note != null && sale.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  context.l10n.noteLabel(sale.note!),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                if (!isVoided)
                  TextButton.icon(
                    icon: Icon(Icons.block, color: theme.colorScheme.error),
                    label: Text(
                      context.l10n.voidSale,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    onPressed: () => VoidSaleDialog.show(context, sale),
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.print_outlined),
                  label: Text(context.l10n.printReceipt),
                  onPressed: () => _printReceipt(context, sale, settings),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: Text(context.l10n.shareReceipt),
                  onPressed: () => _shareReceipt(context, sale, settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<Map<String, Uint8List>> _loadProductImages(Sale sale) async {
    final productRepo = sl<ProductRepository>();
    final images = <String, Uint8List>{};
    for (final item in sale.items) {
      if (images.containsKey(item.productId)) continue;
      try {
        final product = await productRepo.getProductById(item.productId);
        if (product?.imagePath != null) {
          final file = File(product!.imagePath!);
          if (await file.exists()) {
            images[item.productId] = await file.readAsBytes();
          }
        }
      } catch (_) {}
    }
    return images;
  }

  static void _printReceipt(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    try {
      final l = context.l10n;
      final paymentMethodLabel = localizePaymentMethod(
        context,
        sale.paymentMethod,
      );
      final saleSettings = settings.copyWith(
        vatRate: sale.vatRate,
        vatMode: sale.vatMode,
      );
      final productImages = await _loadProductImages(sale);
      await sl<ReceiptPdfService>().printReceipt(
        sale: sale,
        settings: saleSettings,
        productImages: productImages,
        labels: ReceiptLabels(
          receipt: l.receiptLabelReceipt,
          payment: l.receiptLabelPayment,
          paymentMethodLabel: paymentMethodLabel,
          total: l.receiptLabelTotal,
          received: l.receiptLabelReceived,
          change: l.receiptLabelChange,
          note: l.receiptLabelNote,
          vat: l.receiptLabelVat,
          vatIncluded: l.receiptLabelVatIncluded(sale.vatRate),
          subtotal: l.receiptLabelSubtotal,
          itemDiscounts: l.receiptItemDiscounts,
          cartDiscount: l.receiptCartDiscount,
        ),
      );
    } catch (e) {
      AppLogger.error('SaleExpansionTile._printReceipt failed', error: e);
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.errorOccurred);
      }
    }
  }

  static void _shareReceipt(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    try {
      final l = context.l10n;
      final paymentMethodLabel = localizePaymentMethod(
        context,
        sale.paymentMethod,
      );
      final saleSettings = settings.copyWith(
        vatRate: sale.vatRate,
        vatMode: sale.vatMode,
      );
      final productImages = await _loadProductImages(sale);
      await sl<ReceiptPdfService>().shareReceipt(
        sale: sale,
        settings: saleSettings,
        productImages: productImages,
        labels: ReceiptLabels(
          receipt: l.receiptLabelReceipt,
          payment: l.receiptLabelPayment,
          paymentMethodLabel: paymentMethodLabel,
          total: l.receiptLabelTotal,
          received: l.receiptLabelReceived,
          change: l.receiptLabelChange,
          note: l.receiptLabelNote,
          vat: l.receiptLabelVat,
          vatIncluded: l.receiptLabelVatIncluded(sale.vatRate),
          subtotal: l.receiptLabelSubtotal,
          itemDiscounts: l.receiptItemDiscounts,
          cartDiscount: l.receiptCartDiscount,
        ),
      );
    } catch (e) {
      AppLogger.error('SaleExpansionTile._shareReceipt failed', error: e);
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.errorOccurred);
      }
    }
  }
}

class VoidSaleDialog {
  VoidSaleDialog._();

  static Future<void> show(BuildContext context, Sale sale) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(dialogCtx.l10n.voidSale),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dialogCtx.l10n.voidSaleConfirm),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: dialogCtx.l10n.voidReasonHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(dialogCtx.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(dialogCtx.l10n.voidSale),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final reason = reasonController.text.trim();
      context.read<HistoryBloc>().add(
        SaleVoidRequested(
          saleId: sale.id,
          reason: reason.isEmpty ? null : reason,
        ),
      );
    }
    reasonController.dispose();
  }
}
