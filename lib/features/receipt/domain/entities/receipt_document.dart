import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';

/// One printable line. [lineTotal] is **net** after line discount (do not also
/// subtract an aggregate item-discount row — that double-counts).
class ReceiptLineItem extends Equatable {
  const ReceiptLineItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    this.imagePath,
    this.imageThumbnailPath,
    this.imageUrl,
  });

  final String productId;
  final String name;
  final int qty;
  final Money unitPrice;
  final Money lineTotal;
  final String? imagePath;
  final String? imageThumbnailPath;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    productId,
    name,
    qty,
    unitPrice,
    lineTotal,
    imagePath,
    imageThumbnailPath,
    imageUrl,
  ];
}

/// Single source of truth for receipt content (PDF + on-screen previews).
///
/// Money breakdown prefers **persisted [Sale]** fields — never reverse-VAT from
/// payable for completed sales. Line items are net; cart/promo/SC/VAT are
/// separate rows (same order as cart review footer).
class ReceiptDocument extends Equatable {
  const ReceiptDocument({
    required this.shopName,
    required this.showShopInfo,
    required this.address,
    required this.phone,
    required this.receiptNumber,
    required this.createdAt,
    required this.paymentMethodLabel,
    this.paymentLines = const [],
    required this.labels,
    required this.currency,
    required this.dateFormat,
    this.receiptSize = '80mm',
    required this.items,
    required this.itemsNetTotal,
    required this.cartDiscount,
    required this.promotionDiscount,
    required this.serviceCharge,
    required this.serviceChargeRate,
    required this.vatMode,
    required this.vatRate,
    required this.vatAmount,
    required this.pretaxOrNetOfVat,
    required this.total,
    required this.footer,
    required this.isVoided,
    this.customerName,
    this.promotionName,
    this.amountReceived,
    this.changeAmount,
    this.note,
    this.voidReason,
    this.voidedAt,
    this.isReprint = false,
    this.taxId = '',
    this.notTaxInvoiceDisclaimer,
  });

  final String shopName;
  final bool showShopInfo;
  final String address;
  final String phone;

  /// Thai Tax ID (เลขประจำตัวผู้เสียภาษี 13 หลัก).
  /// When non-empty, the receipt qualifies as a tax invoice.
  final String taxId;

  final String receiptNumber;
  final DateTime createdAt;
  final String paymentMethodLabel;

  /// Optional multi-tender detail lines (cash ฿x, PromptPay ฿y).
  final List<String> paymentLines;
  final String? customerName;
  final String? promotionName;

  final ReceiptLabels labels;
  final String currency;
  final String dateFormat;

  /// Paper size for PDF: `58mm` | `80mm` (thermal) or `A4`.
  final String receiptSize;

  final List<ReceiptLineItem> items;

  /// Sum of [ReceiptLineItem.lineTotal] (net of line discounts).
  final Money itemsNetTotal;

  final Money cartDiscount;
  final Money promotionDiscount;
  final Money serviceCharge;
  final double serviceChargeRate;

  /// `NONE` | `INCLUSIVE` | `EXCLUSIVE` (uppercased when building).
  final String vatMode;
  final double vatRate;
  final Money vatAmount;

  /// Stored sale pretax / net-of-VAT base (`Sale.subtotalAmount`).
  final Money pretaxOrNetOfVat;

  final Money total;
  final Money? amountReceived;
  final Money? changeAmount;
  final String? note;
  final String footer;

  final bool isVoided;
  final String? voidReason;
  final DateTime? voidedAt;
  final bool isReprint;

  /// Optional legal disclaimer (sale receipt ≠ tax invoice).
  final String? notTaxInvoiceDisclaimer;

  bool get hasVat {
    final mode = vatMode.toUpperCase();
    return mode != 'NONE' && (vatAmount.isPositive || vatRate > 0);
  }

  bool get isVatInclusive => vatMode.toUpperCase() == 'INCLUSIVE';

  bool get hasBreakdown =>
      cartDiscount.isPositive ||
      promotionDiscount.isPositive ||
      serviceCharge.isPositive ||
      hasVat;

  @override
  List<Object?> get props => [
    shopName,
    showShopInfo,
    address,
    phone,
    taxId,
    receiptNumber,
    createdAt,
    paymentMethodLabel,
    paymentLines,
    customerName,
    promotionName,
    labels,
    currency,
    dateFormat,
    receiptSize,
    items,
    itemsNetTotal,
    cartDiscount,
    promotionDiscount,
    serviceCharge,
    serviceChargeRate,
    vatMode,
    vatRate,
    vatAmount,
    pretaxOrNetOfVat,
    total,
    amountReceived,
    changeAmount,
    note,
    footer,
    isVoided,
    voidReason,
    voidedAt,
    isReprint,
    notTaxInvoiceDisclaimer,
  ];
}
