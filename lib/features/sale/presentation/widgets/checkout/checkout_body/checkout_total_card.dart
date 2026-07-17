import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

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
  final double effectiveTotal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasItemDiscounts = itemsDiscountTotal > 0;
    final hasPromo = promotionDiscountAmount > 0;
    final hasSc = serviceChargeAmount > 0;
    final showLines =
        hasItemDiscounts ||
        hasCartDiscount ||
        hasPromo ||
        hasSc ||
        vatInfo != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (showLines)
              PaymentTotalRow(
                label: context.l10n.receiptLabelSubtotal,
                value: itemsSubtotal,
                currency: currency,
                style: theme.textTheme.bodyMedium,
              ),
            if (hasItemDiscounts)
              PaymentTotalRow(
                label: context.l10n.discountSectionLabel,
                value: -itemsDiscountTotal,
                currency: currency,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            if (hasCartDiscount)
              PaymentTotalRow(
                label: context.l10n.cartDiscount,
                value: -cartDiscountAmount,
                currency: currency,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            if (hasPromo)
              PaymentTotalRow(
                label: context.l10n.receiptLabelPromotionDiscount,
                value: -promotionDiscountAmount,
                currency: currency,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            if (hasSc)
              PaymentTotalRow(
                label: context.l10n.serviceCharge,
                value: serviceChargeAmount,
                currency: currency,
                style: theme.textTheme.bodySmall,
              ),
            if (vatInfo != null && !vatInfo!.isInclusive)
              PaymentTotalRow(
                label: '${context.l10n.receiptLabelVat} $vatRate%',
                value: vatInfo!.vatAmount,
                currency: currency,
                style: theme.textTheme.bodySmall,
              ),
            if (vatInfo != null && vatInfo!.isInclusive)
              PaymentTotalRow(
                label: context.l10n.receiptLabelVatIncluded(
                  vatRate.toStringAsFixed(0),
                ),
                value: vatInfo!.vatAmount,
                currency: currency,
                style: theme.textTheme.bodySmall,
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.totalAmount,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'NotoSansThai',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: MoneyText(
                    key: ValueKey<double>(effectiveTotal),
                    value: effectiveTotal,
                    currency: currency,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: 'NotoSansThai',
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
