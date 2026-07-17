import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
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
        final path = product?.imageThumbnailPath ?? product?.imagePath;
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            if (bytes.lengthInBytes <= 400 * 1024) {
              images[item.productId] = bytes;
            }
          }
        }
      } catch (e) {
        AppLogger.warning('SaleReceiptActions image load failed', error: e);
      }
    }
    return images;
  }

  static Future<ReceiptLabels> _buildLabels(
    BuildContext context,
    Sale sale,
    String paymentMethodLabel, {
    List<String> paymentLines = const [],
  }) async {
    final l = context.l10n;
    String? customerName;
    if (sale.customerId != null) {
      final c = await sl<CustomerRepository>().getCustomerById(
        sale.customerId!,
      );
      customerName = c?.name;
    }
    String? promotionName;
    String? promotionDiscount;
    if (sale.promotionId != null) {
      final p = await sl<PromotionRepository>().getPromotionById(
        sale.promotionId!,
      );
      promotionName = p?.name;
      if (sale.promotionDiscountAmount.isPositive) {
        promotionDiscount = sale.promotionDiscountAmount.value.toStringAsFixed(
          2,
        );
      }
    }
    return ReceiptLabels(
      receipt: l.receiptLabelReceipt,
      payment: l.receiptLabelPayment,
      paymentMethodLabel: paymentMethodLabel,
      paymentLines: paymentLines,
      total: l.receiptLabelTotal,
      received: l.receiptLabelReceived,
      change: l.receiptLabelChange,
      note: l.receiptLabelNote,
      vat: l.receiptLabelVat,
      vatIncluded: l.receiptLabelVatIncluded(sale.vatRate),
      subtotal: l.receiptLabelSubtotal,
      itemDiscounts: l.receiptItemDiscounts,
      cartDiscount: l.receiptCartDiscount,
      serviceCharge: l.serviceCharge,
      customer: l.receiptLabelCustomer,
      customerName: customerName,
      promotion: l.receiptLabelPromotion,
      promotionName: promotionName,
      promotionDiscount: promotionDiscount,
      voided: l.voided,
      voidReason: l.voidReason,
      reprint: l.receiptReprint,
      notTaxInvoice: l.receiptNotTaxInvoice,
    );
  }

  static Future<void> printReceipt(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    try {
      final paymentMethodLabel = formatSalePaymentSummary(
        context,
        sale,
        currency: settings.currency,
      );

      final paymentLines = formatSalePaymentLines(
        context,
        sale,
        currency: settings.currency,
      );
      final saleSettings = settings.copyWith(
        vatRate: sale.vatRate,
        vatMode: sale.vatMode,
      );
      final productImages = await _loadProductImages(sale);
      if (!context.mounted) return;
      final labels = await _buildLabels(
        context,
        sale,
        paymentMethodLabel,
        paymentLines: paymentLines,
      );
      if (!context.mounted) return;
      final l = context.l10n;
      await sl<ReceiptPdfService>().printReceipt(
        sale: sale,
        settings: saleSettings,
        productImages: productImages,
        labels: labels,
        isReprint: true,
        thankYouFallback: l.receiptThankYouDefault,
        notTaxInvoiceDisclaimer: l.receiptNotTaxInvoice,
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
    if (sale.isVoided) {
      if (context.mounted) {
        AppSnackBar.warning(context, context.l10n.receiptShareVoidBlocked);
      }
      return;
    }
    try {
      final paymentMethodLabel = formatSalePaymentSummary(
        context,
        sale,
        currency: settings.currency,
      );

      final paymentLines = formatSalePaymentLines(
        context,
        sale,
        currency: settings.currency,
      );
      final saleSettings = settings.copyWith(
        vatRate: sale.vatRate,
        vatMode: sale.vatMode,
      );
      final productImages = await _loadProductImages(sale);
      if (!context.mounted) return;
      final labels = await _buildLabels(
        context,
        sale,
        paymentMethodLabel,
        paymentLines: paymentLines,
      );
      if (!context.mounted) return;
      final l = context.l10n;
      await sl<ReceiptPdfService>().shareReceipt(
        sale: sale,
        settings: saleSettings,
        productImages: productImages,
        labels: labels,
        isReprint: true,
        thankYouFallback: l.receiptThankYouDefault,
        notTaxInvoiceDisclaimer: l.receiptNotTaxInvoice,
      );
    } catch (e) {
      AppLogger.error('SaleReceiptActions.shareReceipt failed', error: e);
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.errorOccurred);
      }
    }
  }
}
