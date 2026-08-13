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
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/sale_success_hero.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class SaleReceiptDialog {
  SaleReceiptDialog._();

  static ReceiptLabels _labels(
    BuildContext context,
    Sale sale, {
    String? customerName,
    String? promotionName,
  }) {
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
      promotionName: promotionName,
      customer: l.receiptLabelCustomer,
      customerName: customerName,
      voided: l.voided,
      voidReason: l.voidReason,
      reprint: l.receiptReprint,
      notTaxInvoice: l.receiptNotTaxInvoice,
      taxId: l.receiptTaxId,
      taxInvoice: l.receiptTaxInvoice,
      thankYou: l.receiptThankYouDefault,
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

  /// Always-on post-sale success (hero + optional collapsible receipt).
  ///
  /// Opens immediately; product map hydrates async when preview is on.
  static Future<void> show(
    BuildContext context,
    Sale sale,
    Settings settings,
  ) async {
    final l = context.l10n;
    final labels = _labels(context, sale);
    final vatInfo = _vatInfoFromSale(sale);
    final previewStyle = switch (settings.receiptPreviewStyle) {
      'card' => ReceiptPreviewStyle.card,
      'none' => ReceiptPreviewStyle.none,
      _ => ReceiptPreviewStyle.thermal,
    };
    final showPreview =
        settings.showPostSalePreview && settings.receiptPreviewStyle != 'none';

    if (!context.mounted) return;

    final body = _SaleSuccessShell(
      sale: sale,
      settings: settings,
      labels: labels,
      vatInfo: vatInfo,
      previewStyle: previewStyle,
      showPreview: showPreview,
      notTaxInvoice: settings.taxId.trim().isEmpty
          ? l.receiptNotTaxInvoice
          : null,
      thankYou: l.receiptThankYouDefault,
    );

    // Full-height counter sheet (phone + tablet) — sticky Next sale.
    // Non-dismissible: no drag handle (would be a false affordance).
    await PosBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      showDragHandle: false,
      useSafeArea: true,
      builder: (_) => body,
    );
  }

  static Future<Map<String, Product>> hydrateProducts(
    Sale sale,
    ProductRepository productRepo,
  ) async {
    final ids = sale.items.map((i) => i.productId).toSet();
    final map = <String, Product>{};
    await Future.wait(
      ids.map((id) async {
        final product = await productRepo.getProductById(id);
        if (product != null) map[id] = product;
      }),
    );
    return map;
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

class _SaleSuccessShell extends StatefulWidget {
  const _SaleSuccessShell({
    required this.sale,
    required this.settings,
    required this.labels,
    required this.vatInfo,
    required this.previewStyle,
    required this.showPreview,
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
  final String? notTaxInvoice;
  final String thankYou;

  @override
  State<_SaleSuccessShell> createState() => _SaleSuccessShellState();
}

class _SaleSuccessShellState extends State<_SaleSuccessShell> {
  bool _busy = false;
  bool _receiptExpanded = false;
  final Map<String, Product> _productMap = {};
  bool _hydrating = false;

  @override
  void initState() {
    super.initState();
    if (widget.showPreview) {
      _hydrateProducts();
    }
  }

  Future<void> _hydrateProducts() async {
    if (_hydrating) return;
    setState(() => _hydrating = true);
    try {
      final map = await SaleReceiptDialog.hydrateProducts(
        widget.sale,
        sl<ProductRepository>(),
      );
      if (!mounted) return;
      setState(() {
        _productMap
          ..clear()
          ..addAll(map);
        _hydrating = false;
      });
    } catch (e) {
      AppLogger.warning('Success receipt product hydrate failed', error: e);
      if (mounted) setState(() => _hydrating = false);
    }
  }

  Future<void> _ensureProductMap() async {
    if (_productMap.isNotEmpty) return;
    final map = await SaleReceiptDialog.hydrateProducts(
      widget.sale,
      sl<ProductRepository>(),
    );
    if (!mounted) return;
    _productMap
      ..clear()
      ..addAll(map);
  }

  Future<void> _runPrintOrShare(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      AppLogger.error('SaleReceiptDialog print/share failed', error: e);
      if (mounted) {
        AppSnackBar.error(context, context.l10n.receiptPrintFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _receiptPreview() {
    final sale = widget.sale;
    final settings = widget.settings;
    final labels = widget.labels;
    return ReceiptPreview(
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
              imagePath: _productMap[i.productId]?.imagePath,
              imageThumbnailPath: _productMap[i.productId]?.imageThumbnailPath,
              imageUrl: _productMap[i.productId]?.imageUrl,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    final settings = widget.settings;
    final labels = widget.labels;
    final l = context.l10n;
    final height = PosBottomSheet.fractionHeight(
      context,
      PosBottomSheet.successFraction,
    );

    return PopScope(
      canPop: false,
      child: SizedBox(
        key: const ValueKey('sale_success_sheet'),
        height: height,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // No decorative bar — sheet is non-draggable / non-dismissible.
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SaleSuccessHero(
                          sale: sale,
                          currency: settings.currency,
                        ),
                        if (widget.showPreview) ...[
                          const SizedBox(height: 12),
                          ExpansionTile(
                            key: const ValueKey('sale_success_receipt_expand'),
                            initiallyExpanded: false,
                            onExpansionChanged: (v) =>
                                setState(() => _receiptExpanded = v),
                            title: Text(
                              _receiptExpanded ? l.hideReceipt : l.viewReceipt,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            children: [
                              if (_hydrating)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Center(child: _receiptPreview()),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Material(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surface,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SaleSuccessActions(
                        busy: _busy,
                        onNextSale: () => Navigator.pop(context),
                        onPrint: () => _runPrintOrShare(() async {
                          await _ensureProductMap();
                          if (!context.mounted) return;
                          final productImages =
                              await SaleReceiptDialog.loadProductImages(
                                sale,
                                _productMap,
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
                        onShare: () {
                          if (sale.isVoided) {
                            AppSnackBar.warning(
                              context,
                              context.l10n.receiptShareVoidBlocked,
                            );
                            return;
                          }
                          _runPrintOrShare(() async {
                            await _ensureProductMap();
                            if (!context.mounted) return;
                            final productImages =
                                await SaleReceiptDialog.loadProductImages(
                                  sale,
                                  _productMap,
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
                    ),
                  ),
                ),
              ],
            ),
            // Escape route: subtle close button for recovery if dialog freezes.
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                key: const ValueKey('sale_success_escape'),
                icon: const Icon(Icons.close, size: 18),
                iconSize: 18,
                tooltip: l.close,
                onPressed: () => Navigator.of(context).maybePop(),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
