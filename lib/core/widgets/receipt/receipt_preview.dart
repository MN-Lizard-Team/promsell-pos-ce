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
      ),
      ReceiptPreviewStyle.none => const SizedBox.shrink(),
    };
  }
}
