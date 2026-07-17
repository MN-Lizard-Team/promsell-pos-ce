import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class SaleReceiptDialog {
  SaleReceiptDialog._();

  static ReceiptLabels _labels(BuildContext context, Sale sale) {
    final l = context.l10n;
    return ReceiptLabels(
      receipt: l.receiptLabelReceipt,
      payment: l.receiptLabelPayment,
      paymentMethodLabel: formatSalePaymentSummary(context, sale),
      paymentLines: formatSalePaymentLines(context, sale),
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
      promotion: l.receiptLabelPromotion,
      promotionDiscount: l.receiptLabelPromotionDiscount,
      customer: l.receiptLabelCustomer,
      voided: l.voided,
      voidReason: l.voidReason,
      reprint: l.receiptReprint,
      notTaxInvoice: l.receiptNotTaxInvoice,
    );
  }

  /// VAT display from **stored** sale fields (not reverse-engineered).
  static ({
    double subtotal,
    double vatAmount,
    double totalWithVat,
    bool isInclusive,
  })?
  _vatInfoFromSale(Sale sale) {
    final mode = sale.vatMode.toUpperCase();
    if (mode == 'NONE') return null;
    return (
      subtotal: sale.subtotalAmount.value,
      vatAmount: sale.vatAmount.value,
      totalWithVat: sale.totalAmount.value,
      isInclusive: mode == 'INCLUSIVE',
    );
  }

  static Future<void> show(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    final l = context.l10n;
    final productRepo = sl<ProductRepository>();
    final labels = _labels(context, sale);
    final vatInfo = _vatInfoFromSale(sale);
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

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _SaleReceiptDialogBody(
        sale: sale,
        settings: settings,
        labels: labels,
        vatInfo: vatInfo,
        previewStyle: previewStyle,
        showPreview: showPreview,
        productMap: productMap,
        notTaxInvoice: l.receiptNotTaxInvoice,
        thankYou: l.receiptThankYouDefault,
      ),
    );
  }

  static Future<Map<String, Uint8List>> loadProductImages(
    Sale sale,
    Map<String, Product> productMap,
  ) async {
    final images = <String, Uint8List>{};
    for (final item in sale.items) {
      if (images.containsKey(item.productId)) continue;
      final product = productMap[item.productId];
      final path = product?.imageThumbnailPath ?? product?.imagePath;
      if (path == null) continue;
      try {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // Soft cap ~400KB per image for PDF memory.
          if (bytes.lengthInBytes <= 400 * 1024) {
            images[item.productId] = bytes;
          }
        }
      } catch (e) {
        AppLogger.warning('Failed to load product image', error: e);
      }
    }
    return images;
  }
}

class _SaleReceiptDialogBody extends StatefulWidget {
  const _SaleReceiptDialogBody({
    required this.sale,
    required this.settings,
    required this.labels,
    required this.vatInfo,
    required this.previewStyle,
    required this.showPreview,
    required this.productMap,
    required this.notTaxInvoice,
    required this.thankYou,
  });

  final Sale sale;
  final Settings settings;
  final ReceiptLabels labels;
  final ({
    double subtotal,
    double vatAmount,
    double totalWithVat,
    bool isInclusive,
  })?
  vatInfo;
  final ReceiptPreviewStyle previewStyle;
  final bool showPreview;
  final Map<String, Product> productMap;
  final String notTaxInvoice;
  final String thankYou;

  @override
  State<_SaleReceiptDialogBody> createState() => _SaleReceiptDialogBodyState();
}

class _SaleReceiptDialogBodyState extends State<_SaleReceiptDialogBody> {
  bool _busy = false;

  Future<void> _runPrintOrShare(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      AppLogger.error('SaleReceiptDialog print/share failed', error: e);
      if (mounted) {
        AppSnackBar.error(context, context.l10n.errorOccurred);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sale = widget.sale;
    final settings = widget.settings;
    final labels = widget.labels;

    return AlertDialog(
      title: Text('${l.receiptLabelReceipt} #${sale.receiptNumber ?? sale.id}'),
      content: SingleChildScrollView(
        child: widget.showPreview
            ? ReceiptPreview(
                settings: settings,
                labels: labels,
                style: widget.previewStyle,
                items: sale.items
                    .map(
                      (i) => ReceiptPreviewItem(
                        name: i.productName,
                        qty: i.qty,
                        price: i.price.value,
                        subtotal: i.subtotal.value,
                        imagePath: widget.productMap[i.productId]?.imagePath,
                        imageThumbnailPath:
                            widget.productMap[i.productId]?.imageThumbnailPath,
                        imageUrl: widget.productMap[i.productId]?.imageUrl,
                      ),
                    )
                    .toList(),
                total: sale.totalAmount.value,
                vatInfo: widget.vatInfo,
                paymentMethod: labels.paymentMethodLabel,
                amountReceived: sale.amountReceived?.value,
                changeAmount: sale.changeAmount?.value,
                note: sale.note,
                receiptNumber: sale.receiptNumber,
                createdAt: sale.createdAt,
                cartDiscount: sale.discountAmount.isPositive
                    ? sale.discountAmount.value
                    : null,
                promotionDiscount: sale.promotionDiscountAmount.isPositive
                    ? sale.promotionDiscountAmount.value
                    : null,
                serviceCharge: sale.serviceChargeAmount.isPositive
                    ? sale.serviceChargeAmount.value
                    : null,
                serviceChargeRate: sale.serviceChargeRate,
                isVoided: sale.isVoided,
                voidReason: sale.voidReason,
                notTaxInvoiceDisclaimer: widget.notTaxInvoice,
                footerOverride: settings.receiptNote.isNotEmpty
                    ? settings.receiptNote
                    : widget.thankYou,
              )
            : Text(l.saleSavedSuccess),
      ),
      actions: [
        TextButton.icon(
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print_outlined),
          label: Text(l.printReceipt),
          onPressed: _busy
              ? null
              : () => _runPrintOrShare(() async {
                  final productImages =
                      await SaleReceiptDialog.loadProductImages(
                        sale,
                        widget.productMap,
                      );
                  if (!context.mounted) return;
                  await sl<ReceiptPdfService>().printReceipt(
                    sale: sale,
                    settings: settings.copyWith(
                      vatRate: sale.vatRate,
                      vatMode: sale.vatMode,
                    ),
                    labels: labels,
                    productImages: productImages,
                    thankYouFallback: widget.thankYou,
                    notTaxInvoiceDisclaimer: widget.notTaxInvoice,
                  );
                }),
        ),
        TextButton.icon(
          icon: const Icon(Icons.share_outlined),
          label: Text(l.shareReceipt),
          onPressed: _busy
              ? null
              : () {
                  if (sale.isVoided) {
                    AppSnackBar.warning(context, l.receiptShareVoidBlocked);
                    return;
                  }
                  _runPrintOrShare(() async {
                    final productImages =
                        await SaleReceiptDialog.loadProductImages(
                          sale,
                          widget.productMap,
                        );
                    if (!context.mounted) return;
                    await sl<ReceiptPdfService>().shareReceipt(
                      sale: sale,
                      settings: settings.copyWith(
                        vatRate: sale.vatRate,
                        vatMode: sale.vatMode,
                      ),
                      labels: labels,
                      productImages: productImages,
                      thankYouFallback: widget.thankYou,
                      notTaxInvoiceDisclaimer: widget.notTaxInvoice,
                    );
                  });
                },
        ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l.done),
        ),
      ],
    );
  }
}
