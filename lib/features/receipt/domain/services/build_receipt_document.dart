import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_document.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/domain/services/receipt_line_name.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Builds a [ReceiptDocument] from a persisted [Sale] (financial SSOT).
///
/// Line totals are **net** (already after item discounts). Aggregate item-discount
/// rows are intentionally omitted to avoid double-counting.
@lazySingleton
class BuildReceiptDocument {
  const BuildReceiptDocument();

  ReceiptDocument fromSale({
    required Sale sale,
    required Settings settings,
    required ReceiptLabels labels,
    bool isReprint = false,
    String? thankYouFallback,
    String? notTaxInvoiceDisclaimer,
    Map<
      String,
      ({String? imagePath, String? imageThumbnailPath, String? imageUrl})
    >?
    productImages,
  }) {
    final items = sale.items.map((i) {
      final img = productImages?[i.productId];
      return ReceiptLineItem(
        productId: i.productId,
        name: receiptLineName(
          productName: i.productName,
          selectedOptions: i.selectedOptions,
        ),
        qty: i.qty,
        unitPrice: i.price,
        lineTotal: i.subtotal,
        imagePath: img?.imagePath,
        imageThumbnailPath: img?.imageThumbnailPath,
        imageUrl: img?.imageUrl,
      );
    }).toList();

    final itemsNet = items.fold<Money>(
      Money.zero,
      (sum, i) => sum + i.lineTotal,
    );

    final footer = settings.receiptNote.isNotEmpty
        ? settings.receiptNote
        : (thankYouFallback ?? 'Thank you!');

    final vatMode = sale.vatMode.toUpperCase();

    // Show cash received/change only when there is a cash tender leg.
    final cashLeg = saleCashTenderTotal(sale);
    final showCashDrawer = cashLeg.isPositive;
    final amountReceived = showCashDrawer ? sale.amountReceived : null;
    final changeAmount = showCashDrawer ? sale.changeAmount : null;

    return ReceiptDocument(
      shopName: settings.shopName,
      showShopInfo: settings.showShopInfoOnReceipt,
      address: settings.address,
      phone: settings.phone,
      taxId: settings.taxId,
      receiptNumber: sale.receiptNumber ?? sale.id,
      createdAt: sale.createdAt,
      paymentMethodLabel: labels.paymentMethodLabel,
      paymentLines: labels.paymentLines,
      customerName: labels.customerName,
      promotionName: labels.promotionName,
      labels: labels,
      currency: settings.currency,
      dateFormat: settings.dateFormat,
      receiptSize: settings.receiptSize,
      items: items,
      itemsNetTotal: itemsNet,
      cartDiscount: sale.discountAmount,
      promotionDiscount: sale.promotionDiscountAmount,
      serviceCharge: sale.serviceChargeAmount,
      serviceChargeRate: sale.serviceChargeRate,
      vatMode: vatMode,
      vatRate: sale.vatRate,
      vatAmount: sale.vatAmount,
      pretaxOrNetOfVat: sale.subtotalAmount,
      total: sale.totalAmount,
      amountReceived: amountReceived,
      changeAmount: changeAmount,
      note: sale.note,
      footer: footer,
      isVoided: sale.isVoided,
      voidReason: sale.voidReason,
      voidedAt: sale.voidedAt,
      isReprint: isReprint,
      // Show "not a tax invoice" disclaimer only when no valid Tax ID is set.
      notTaxInvoiceDisclaimer: settings.taxId.trim().isEmpty
          ? notTaxInvoiceDisclaimer
          : null,
    );
  }
}
