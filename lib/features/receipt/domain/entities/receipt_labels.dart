/// Labels for receipt text that must be localized by the caller.
class ReceiptLabels {
  const ReceiptLabels({
    required this.receipt,
    required this.payment,
    required this.paymentMethodLabel,
    this.paymentLines = const [],
    required this.total,
    required this.received,
    required this.change,
    required this.note,
    required this.vat,
    required this.vatIncluded,
    required this.subtotal,
    required this.itemDiscounts,
    required this.cartDiscount,
    this.serviceCharge,
    this.customer,
    this.customerName,
    this.promotion,
    this.promotionName,
    this.promotionDiscount,
    this.voided,
    this.voidReason,
    this.voidedAt,
    this.reprint,
    this.notTaxInvoice,
  });

  final String receipt;
  final String payment;
  final String paymentMethodLabel;

  /// Multi-tender detail lines for PDF/preview (optional).
  final List<String> paymentLines;
  final String total;
  final String received;
  final String change;
  final String note;
  final String vat;
  final String vatIncluded;
  final String subtotal;
  final String itemDiscounts;
  final String cartDiscount;

  /// Localized "Service charge" row label.
  final String? serviceCharge;

  /// Localized "Customer" label; optional name when attached to sale.
  final String? customer;
  final String? customerName;

  /// Localized "Promotion" label; optional name/discount when applied.
  final String? promotion;
  final String? promotionName;
  final String? promotionDiscount;

  final String? voided;
  final String? voidReason;
  final String? voidedAt;
  final String? reprint;
  final String? notTaxInvoice;
}
