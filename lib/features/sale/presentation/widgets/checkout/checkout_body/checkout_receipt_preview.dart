import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class CheckoutReceiptPreview extends StatelessWidget {
  const CheckoutReceiptPreview({
    super.key,
    required this.settings,
    required this.items,
    required this.effectiveTotal,
    required this.vatInfo,
    required this.method,
    required this.noteText,
    required this.amountReceived,
    required this.changeAmount,
    required this.onTapPreview,
  });

  final Settings settings;
  final List<CartItem> items;
  final double effectiveTotal;
  final dynamic vatInfo;
  final String method;
  final String noteText;
  final double? amountReceived;
  final double? changeAmount;
  final VoidCallback onTapPreview;

  List<ReceiptPreviewItem> get _previewItems => items
      .map(
        (i) => ReceiptPreviewItem(
          name: i.product.name,
          qty: i.qty,
          price: i.product.price,
          subtotal: i.subtotal,
          imagePath: i.product.imagePath,
          imageThumbnailPath: i.product.imageThumbnailPath,
          imageUrl: i.product.imageUrl,
        ),
      )
      .toList();

  ReceiptLabels _buildLabels(BuildContext context) {
    return ReceiptLabels(
      receipt: context.l10n.receiptLabelReceipt,
      payment: context.l10n.receiptLabelPayment,
      paymentMethodLabel: localizePaymentMethod(context, method),
      total: context.l10n.receiptLabelTotal,
      received: context.l10n.receiptLabelReceived,
      change: context.l10n.receiptLabelChange,
      note: context.l10n.receiptLabelNote,
      vat: context.l10n.receiptLabelVat,
      vatIncluded: context.l10n.receiptLabelVatIncluded(settings.vatRate),
      subtotal: context.l10n.receiptLabelSubtotal,
      itemDiscounts: context.l10n.receiptItemDiscounts,
      cartDiscount: context.l10n.receiptCartDiscount,
    );
  }

  ReceiptPreviewStyle get _style => switch (settings.receiptPreviewStyle) {
    'card' => ReceiptPreviewStyle.card,
    'none' => ReceiptPreviewStyle.none,
    _ => ReceiptPreviewStyle.thermal,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = _buildLabels(context);
    final previewItems = _previewItems;
    final note = noteText.trim().isEmpty ? null : noteText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.receiptPreview,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTapPreview,
          child: ReceiptPreview(
            settings: settings,
            labels: labels,
            style: _style,
            items: previewItems,
            total: effectiveTotal,
            vatInfo: vatInfo,
            paymentMethod: method,
            amountReceived: amountReceived,
            changeAmount: changeAmount,
            note: note,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
