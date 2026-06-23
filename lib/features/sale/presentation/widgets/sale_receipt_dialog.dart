import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/core/widgets/receipt_preview.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class SaleReceiptDialog {
  SaleReceiptDialog._();

  static Future<void> show(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    final l = context.l10n;
    final productRepo = sl<ProductRepository>();
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

    final productMap = <String, Product>{};
    for (final item in sale.items) {
      if (!productMap.containsKey(item.productId)) {
        final product = await productRepo.getProductById(item.productId);
        if (product != null) productMap[item.productId] = product;
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
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
                          imagePath: productMap[i.productId]?.imagePath,
                          imageThumbnailPath:
                              productMap[i.productId]?.imageThumbnailPath,
                          imageUrl: productMap[i.productId]?.imageUrl,
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
              final productImages = await _loadProductImages(sale, productMap);
              await sl<ReceiptPdfService>().printReceipt(
                sale: sale,
                settings: settings.copyWith(
                  vatRate: sale.vatRate,
                  vatMode: sale.vatMode,
                ),
                labels: labels,
                productImages: productImages,
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: Text(l.shareReceipt),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final productImages = await _loadProductImages(sale, productMap);
              await sl<ReceiptPdfService>().shareReceipt(
                sale: sale,
                settings: settings.copyWith(
                  vatRate: sale.vatRate,
                  vatMode: sale.vatMode,
                ),
                labels: labels,
                productImages: productImages,
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, Uint8List>> _loadProductImages(
    Sale sale,
    Map<String, Product> productMap,
  ) async {
    final images = <String, Uint8List>{};
    for (final item in sale.items) {
      if (images.containsKey(item.productId)) continue;
      final product = productMap[item.productId];
      if (product?.imagePath != null) {
        try {
          final file = File(product!.imagePath!);
          if (await file.exists()) {
            images[item.productId] = await file.readAsBytes();
          }
        } catch (_) {}
      }
    }
    return images;
  }
}
