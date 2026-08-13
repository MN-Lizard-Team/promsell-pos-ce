import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/domain/services/receipt_line_name.dart';
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
    this.cartDiscount,
    this.promotionDiscount,
    this.serviceCharge,
    this.serviceChargeRate,
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
  final double? cartDiscount;
  final double? promotionDiscount;
  final double? serviceCharge;
  final double? serviceChargeRate;

  List<ReceiptPreviewItem> get _previewItems => items
      .map(
        (i) => ReceiptPreviewItem(
          name: receiptLineName(
            productName: i.product.name,
            selectedOptions: i.selectedOptions,
          ),
          qty: i.qty,
          price: i.product.price.value,
          subtotal: i.subtotal.value,
          imagePath: i.product.imagePath,
          imageThumbnailPath: i.product.imageThumbnailPath,
          imageUrl: i.product.imageUrl,
        ),
      )
      .toList();

  ReceiptLabels _buildLabels(BuildContext context) {
    final l = context.l10n;
    return ReceiptLabels(
      receipt: l.receiptLabelReceipt,
      payment: l.receiptLabelPayment,
      paymentMethodLabel: localizePaymentMethod(context, method),
      total: l.receiptLabelTotal,
      received: l.receiptLabelReceived,
      change: l.receiptLabelChange,
      note: l.receiptLabelNote,
      vat: l.receiptLabelVat,
      vatIncluded: l.receiptLabelVatIncluded(settings.vatRate),
      subtotal: l.receiptLabelSubtotal,
      itemDiscounts: l.receiptItemDiscounts,
      cartDiscount: l.receiptCartDiscount,
      serviceCharge: l.serviceCharge,
      promotion: l.receiptLabelPromotion,
      promotionDiscount: l.receiptLabelPromotionDiscount,
      notTaxInvoice: l.receiptNotTaxInvoice,
      taxId: l.receiptTaxId,
      taxInvoice: l.receiptTaxInvoice,
      thankYou: l.receiptThankYouDefault,
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
            // Localized method — not raw `cash` / `promptpay`.
            paymentMethod: labels.paymentMethodLabel,
            amountReceived: amountReceived,
            changeAmount: changeAmount,
            note: note,
            cartDiscount: cartDiscount,
            promotionDiscount: promotionDiscount,
            serviceCharge: serviceCharge,
            serviceChargeRate: serviceChargeRate,
            notTaxInvoiceDisclaimer: labels.notTaxInvoice,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
