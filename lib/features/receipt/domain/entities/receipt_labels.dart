/// Labels for receipt text that must be localized by the caller.
class ReceiptLabels {
  const ReceiptLabels({
    required this.receipt,
    required this.payment,
    required this.paymentMethodLabel,
    required this.total,
    required this.received,
    required this.change,
    required this.note,
    required this.vat,
    required this.vatIncluded,
    required this.subtotal,
    required this.itemDiscounts,
    required this.cartDiscount,
  });

  final String receipt;
  final String payment;
  final String paymentMethodLabel;
  final String total;
  final String received;
  final String change;
  final String note;
  final String vat;
  final String vatIncluded;
  final String subtotal;
  final String itemDiscounts;
  final String cartDiscount;
}
