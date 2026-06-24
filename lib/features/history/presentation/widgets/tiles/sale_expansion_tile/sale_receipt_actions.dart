import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class SaleReceiptActions {
  SaleReceiptActions._();

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

  static ReceiptLabels _buildLabels(
    BuildContext context,
    Sale sale,
    String paymentMethodLabel,
  ) {
    final l = context.l10n;
    return ReceiptLabels(
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
    );
  }

  static Future<void> printReceipt(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    try {
      final paymentMethodLabel = localizePaymentMethod(
        context,
        sale.paymentMethod,
      );
      final saleSettings = settings.copyWith(
        vatRate: sale.vatRate,
        vatMode: sale.vatMode,
      );
      final productImages = await _loadProductImages(sale);
      if (!context.mounted) return;
      await sl<ReceiptPdfService>().printReceipt(
        sale: sale,
        settings: saleSettings,
        productImages: productImages,
        labels: _buildLabels(context, sale, paymentMethodLabel),
      );
    } catch (e) {
      AppLogger.error('SaleReceiptActions.printReceipt failed', error: e);
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.errorOccurred);
      }
    }
  }

  static Future<void> shareReceipt(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    try {
      final paymentMethodLabel = localizePaymentMethod(
        context,
        sale.paymentMethod,
      );
      final saleSettings = settings.copyWith(
        vatRate: sale.vatRate,
        vatMode: sale.vatMode,
      );
      final productImages = await _loadProductImages(sale);
      if (!context.mounted) return;
      await sl<ReceiptPdfService>().shareReceipt(
        sale: sale,
        settings: saleSettings,
        productImages: productImages,
        labels: _buildLabels(context, sale, paymentMethodLabel),
      );
    } catch (e) {
      AppLogger.error('SaleReceiptActions.shareReceipt failed', error: e);
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.errorOccurred);
      }
    }
  }
}
