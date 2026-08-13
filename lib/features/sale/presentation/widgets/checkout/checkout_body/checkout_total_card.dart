import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

/// Collapsible bill breakdown only — **no** second amount-due hero.
///
/// Payable spotlight lives on [CheckoutStickyPayable] + confirm dock.
/// When there are no discount/VAT/SC lines, this widget is empty.
class CheckoutTotalCard extends StatelessWidget {
  const CheckoutTotalCard({
    super.key,
    required this.itemsSubtotal,
    required this.itemsDiscountTotal,
    required this.hasCartDiscount,
    required this.cartDiscountAmount,
    this.promotionDiscountAmount = 0,
    this.serviceChargeAmount = 0,
    required this.vatInfo,
    required this.vatRate,
    required this.effectiveTotal,
    required this.currency,
    this.initiallyExpanded = false,
  });

  final double itemsSubtotal;
  final double itemsDiscountTotal;
  final bool hasCartDiscount;
  final double cartDiscountAmount;
  final double promotionDiscountAmount;
  final double serviceChargeAmount;
  final ({
    double subtotal,
    double vatAmount,
    double totalWithVat,
    bool isInclusive,
  })?
  vatInfo;
  final double vatRate;

  /// Kept for call-site compatibility; not shown as a hero row.
  final double effectiveTotal;
  final String currency;
  final bool initiallyExpanded;

  bool get _hasLines =>
      itemsDiscountTotal > 0 ||
      hasCartDiscount ||
      promotionDiscountAmount > 0 ||
      serviceChargeAmount > 0 ||
      vatInfo != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasLines) return const SizedBox.shrink();

    return _CheckoutBreakdownTicket(
      itemsSubtotal: itemsSubtotal,
      itemsDiscountTotal: itemsDiscountTotal,
      hasCartDiscount: hasCartDiscount,
      cartDiscountAmount: cartDiscountAmount,
      promotionDiscountAmount: promotionDiscountAmount,
      serviceChargeAmount: serviceChargeAmount,
      vatInfo: vatInfo,
      vatRate: vatRate,
      currency: currency,
      initiallyExpanded: initiallyExpanded,
    );
  }
}

class _CheckoutBreakdownTicket extends StatefulWidget {
  const _CheckoutBreakdownTicket({
    required this.itemsSubtotal,
    required this.itemsDiscountTotal,
    required this.hasCartDiscount,
    required this.cartDiscountAmount,
    required this.promotionDiscountAmount,
    required this.serviceChargeAmount,
    required this.vatInfo,
    required this.vatRate,
    required this.currency,
    required this.initiallyExpanded,
  });

  final double itemsSubtotal;
  final double itemsDiscountTotal;
  final bool hasCartDiscount;
  final double cartDiscountAmount;
  final double promotionDiscountAmount;
  final double serviceChargeAmount;
  final ({
    double subtotal,
    double vatAmount,
    double totalWithVat,
    bool isInclusive,
  })?
  vatInfo;
  final double vatRate;
  final String currency;
  final bool initiallyExpanded;

  @override
  State<_CheckoutBreakdownTicket> createState() =>
      _CheckoutBreakdownTicketState();
}

class _CheckoutBreakdownTicketState extends State<_CheckoutBreakdownTicket> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final w = widget;

    return Material(
      key: const ValueKey('sale_checkout_breakdown'),
      elevation: pos.elevFlat,
      color: pos.billStubPaper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pos.billStubRadius),
        side: BorderSide(color: pos.billStubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(pos.billStubRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.cartBillDetails,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontFamily: 'NotoSansThai',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 22,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                child: Column(
                  children: [
                    PaymentTotalRow(
                      label: context.l10n.receiptLabelSubtotal,
                      value: w.itemsSubtotal,
                      currency: w.currency,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (w.itemsDiscountTotal > 0)
                      PaymentTotalRow(
                        label: context.l10n.discountSectionLabel,
                        value: -w.itemsDiscountTotal,
                        currency: w.currency,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    if (w.hasCartDiscount)
                      PaymentTotalRow(
                        label: context.l10n.cartDiscount,
                        value: -w.cartDiscountAmount,
                        currency: w.currency,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    if (w.promotionDiscountAmount > 0)
                      PaymentTotalRow(
                        label: context.l10n.receiptLabelPromotionDiscount,
                        value: -w.promotionDiscountAmount,
                        currency: w.currency,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    if (w.serviceChargeAmount > 0)
                      PaymentTotalRow(
                        label: context.l10n.serviceCharge,
                        value: w.serviceChargeAmount,
                        currency: w.currency,
                        style: theme.textTheme.bodySmall,
                      ),
                    if (w.vatInfo != null && !w.vatInfo!.isInclusive)
                      PaymentTotalRow(
                        label: '${context.l10n.receiptLabelVat} ${w.vatRate}%',
                        value: w.vatInfo!.vatAmount,
                        currency: w.currency,
                        style: theme.textTheme.bodySmall,
                      ),
                    if (w.vatInfo != null && w.vatInfo!.isInclusive)
                      PaymentTotalRow(
                        label: context.l10n.receiptLabelVatIncluded(
                          w.vatRate.toStringAsFixed(0),
                        ),
                        value: w.vatInfo!.vatAmount,
                        currency: w.currency,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
