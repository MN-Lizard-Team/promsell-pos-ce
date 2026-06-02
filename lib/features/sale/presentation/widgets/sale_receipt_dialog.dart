import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/core/widgets/receipt_preview.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

class SaleReceiptDialog {
  SaleReceiptDialog._();

  static void show(BuildContext context, Sale sale, AppSettings settings) {
    final l = context.l10n;
    final labels = ReceiptLabels(
      receipt: l.receiptLabelReceipt,
      payment: l.receiptLabelPayment,
      paymentMethodLabel: localizePaymentMethod(context, sale.paymentMethod),
      total: l.receiptLabelTotal,
      received: l.receiptLabelReceived,
      change: l.receiptLabelChange,
      note: l.receiptLabelNote,
      vat: l.receiptLabelVat,
      vatIncluded: l.receiptLabelVatIncluded(sale.vatRate),
      subtotal: l.receiptLabelSubtotal,
      itemDiscounts: l.receiptItemDiscounts,
      cartDiscount: l.receiptCartDiscount,
    );
    final vatInfo = sl<ReceiptPdfService>().calculateVat(
      total: sale.totalAmount,
      rate: sale.vatRate,
      mode: sale.vatMode,
      isTotalPreTax: false,
    );
    final previewStyle = switch (settings.receiptPreviewStyle) {
      'card' => ReceiptPreviewStyle.card,
      'none' => ReceiptPreviewStyle.none,
      _ => ReceiptPreviewStyle.thermal,
    };
    final showPreview =
        settings.showPostSalePreview && settings.receiptPreviewStyle != 'none';
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          '${l.receiptLabelReceipt} #${sale.receiptNumber ?? sale.id}',
        ),
        content: SingleChildScrollView(
          child: showPreview
              ? ReceiptPreview(
                  settings: settings,
                  labels: labels,
                  style: previewStyle,
                  items: sale.items
                      .map(
                        (i) => ReceiptPreviewItem(
                          name: i.productName,
                          qty: i.qty,
                          price: i.price,
                          subtotal: i.subtotal,
                        ),
                      )
                      .toList(),
                  total: sale.totalAmount,
                  vatInfo: vatInfo,
                  paymentMethod: sale.paymentMethod,
                  amountReceived: sale.amountReceived,
                  changeAmount: sale.changeAmount,
                  note: sale.note,
                  receiptNumber: sale.receiptNumber,
                  createdAt: sale.createdAt,
                )
              : Text(l.saleSavedSuccess),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.print_outlined),
            label: Text(l.printReceipt),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await sl<ReceiptPdfService>().printReceipt(
                sale: sale,
                settings: settings.copyWith(
                  vatRate: sale.vatRate,
                  vatMode: sale.vatMode,
                ),
                labels: labels,
              );
              if (context.mounted) {
                context.read<SaleBloc>().add(const SaleReset());
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: Text(l.shareReceipt),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await sl<ReceiptPdfService>().shareReceipt(
                sale: sale,
                settings: settings.copyWith(
                  vatRate: sale.vatRate,
                  vatMode: sale.vatMode,
                ),
                labels: labels,
              );
              if (context.mounted) {
                context.read<SaleBloc>().add(const SaleReset());
              }
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<SaleBloc>().add(const SaleReset());
            },
            child: Text(l.cancel),
          ),
        ],
      ),
    );
  }
}
