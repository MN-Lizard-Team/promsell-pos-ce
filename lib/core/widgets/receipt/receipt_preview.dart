import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview/receipt_preview_card.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview/receipt_preview_data.dart';
export 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview/receipt_preview_data.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview/receipt_preview_thermal.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({
    super.key,
    required this.settings,
    required this.labels,
    required this.style,
    required this.items,
    required this.total,
    this.vatInfo,
    this.paymentMethod,
    this.amountReceived,
    this.changeAmount,
    this.note,
    this.receiptNumber,
    this.createdAt,
    this.cartDiscount,
    this.promotionDiscount,
    this.serviceCharge,
    this.serviceChargeRate,
    this.isVoided = false,
    this.voidReason,
    this.isReprint = false,
    this.notTaxInvoiceDisclaimer,
    this.footerOverride,
  });

  final Settings settings;
  final ReceiptLabels labels;
  final ReceiptPreviewStyle style;
  final List<ReceiptPreviewItem> items;
  final double total;
  final ({
    double subtotal,
    double vatAmount,
    double totalWithVat,
    bool isInclusive,
  })?
  vatInfo;
  final String? paymentMethod;
  final double? amountReceived;
  final double? changeAmount;
  final String? note;
  final String? receiptNumber;
  final DateTime? createdAt;
  final double? cartDiscount;
  final double? promotionDiscount;
  final double? serviceCharge;
  final double? serviceChargeRate;
  final bool isVoided;
  final String? voidReason;
  final bool isReprint;
  final String? notTaxInvoiceDisclaimer;
  final String? footerOverride;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      ReceiptPreviewStyle.thermal => ReceiptPreviewThermal(
        settings: settings,
        labels: labels,
        items: items,
        total: total,
        vatInfo: vatInfo,
        paymentMethod: paymentMethod,
        amountReceived: amountReceived,
        changeAmount: changeAmount,
        note: note,
        receiptNumber: receiptNumber,
        createdAt: createdAt,
        cartDiscount: cartDiscount,
        promotionDiscount: promotionDiscount,
        serviceCharge: serviceCharge,
        serviceChargeRate: serviceChargeRate,
        isVoided: isVoided,
        voidReason: voidReason,
        isReprint: isReprint,
        notTaxInvoiceDisclaimer: notTaxInvoiceDisclaimer,
        footerOverride: footerOverride,
      ),
      ReceiptPreviewStyle.card => ReceiptPreviewCard(
        settings: settings,
        labels: labels,
        items: items,
        total: total,
        vatInfo: vatInfo,
        paymentMethod: paymentMethod,
        amountReceived: amountReceived,
        changeAmount: changeAmount,
        note: note,
        receiptNumber: receiptNumber,
        createdAt: createdAt,
        cartDiscount: cartDiscount,
        promotionDiscount: promotionDiscount,
        serviceCharge: serviceCharge,
        serviceChargeRate: serviceChargeRate,
        isVoided: isVoided,
        voidReason: voidReason,
        isReprint: isReprint,
        notTaxInvoiceDisclaimer: notTaxInvoiceDisclaimer,
        footerOverride: footerOverride,
      ),
      ReceiptPreviewStyle.none => const SizedBox.shrink(),
    };
  }
}
