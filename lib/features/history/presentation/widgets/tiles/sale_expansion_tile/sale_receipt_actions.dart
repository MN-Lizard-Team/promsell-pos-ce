import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class SaleReceiptActions {
  SaleReceiptActions._();

  /// Guards against concurrent print/share operations per sale.
  /// Using a Set of sale IDs allows printing sale A while sharing sale B,
  /// and prevents a stuck flag from blocking all future operations.
  static final Set<String> _busySaleIds = <String>{};

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
            if (bytes.lengthInBytes > 0 && bytes.lengthInBytes <= 400 * 1024) {
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
    if (sale.promotionId != null) {
      final p = await sl<PromotionRepository>().getPromotionById(
        sale.promotionId!,
      );
      promotionName = p?.name;
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
      // Row title only — never the money amount (amount is a separate column).
      promotionDiscount: l.receiptLabelPromotionDiscount,
      voided: l.voided,
      voidReason: l.voidReason,
      reprint: l.receiptReprint,
      notTaxInvoice: l.receiptNotTaxInvoice,
      taxId: l.receiptTaxId,
      taxInvoice: l.receiptTaxInvoice,
      thankYou: l.receiptThankYouDefault,
    );
  }

  static Future<void> printReceipt(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    if (!await ensureAppUnlocked(
      context,
      title: context.l10n.appLockConfirmPin,
    )) {
      return;
    }
    if (_busySaleIds.contains(sale.id)) return;
    _busySaleIds.add(sale.id);
    try {
      await sl<AppLockService>().requireSensitiveSession();
      if (!context.mounted) return;
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
      if (context.mounted) {
        AppSnackBar.success(context, l.receiptPrintSuccess);
      }
    } catch (e) {
      AppLogger.error('SaleReceiptActions.printReceipt failed', error: e);
      if (context.mounted) {
        final l = context.l10n;
        AppSnackBar.error(
          context,
          e is Exception ? l.receiptPrintFailed : l.receiptPdfFailed,
        );
      }
    } finally {
      _busySaleIds.remove(sale.id);
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
    if (!await ensureAppUnlocked(
      context,
      title: context.l10n.appLockConfirmPin,
    )) {
      return;
    }
    if (_busySaleIds.contains(sale.id)) return;
    _busySaleIds.add(sale.id);
    try {
      await sl<AppLockService>().requireSensitiveSession();
      if (!context.mounted) return;
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
      if (context.mounted) {
        AppSnackBar.success(context, l.receiptShareSuccess);
      }
    } catch (e) {
      AppLogger.error('SaleReceiptActions.shareReceipt failed', error: e);
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.receiptShareFailed);
      }
    } finally {
      _busySaleIds.remove(sale.id);
    }
  }
}
