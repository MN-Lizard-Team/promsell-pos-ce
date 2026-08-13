import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_dotted_line_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_park_actions.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Sticky settle dock: Amount due + Park / Pay.
///
/// Money SSOT: [CartState.payableTotals] only.
class CartReviewFooter extends StatefulWidget {
  const CartReviewFooter({super.key});

  @override
  State<CartReviewFooter> createState() => _CartReviewFooterState();
}

class _CartReviewFooterState extends State<CartReviewFooter> {
  bool? _expandedOverride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final settings = context.read<SettingsCubit>().state.settings;
        final payableTotals = state.payableTotals(settings);
        final itemDiscountTotal = state.items.fold(
          Money.zero,
          (s, i) => s + i.discountAmount,
        );
        final hasPromo = state.promotionDiscountAmount > 0;
        final hasBreakdown =
            itemDiscountTotal > Money.zero ||
            state.hasCartDiscount ||
            hasPromo ||
            payableTotals.serviceChargeAmount > Money.zero ||
            payableTotals.vatAmount > Money.zero;
        // Collapse by default (amount due first); expand for breakdown.
        final expanded = _expandedOverride ?? false;
        final pos = context.posTheme;
        final due = payableTotals.payableTotal;
        final amountLabel =
            '$currency${due.value.toStringAsFixed(due.value == due.value.roundToDouble() ? 0 : 2)}';

        // Ticket stub continuum — elevFlat (no second floating card).
        return Material(
          elevation: pos.elevFlat,
          color: pos.billStubPaper,
          surfaceTintColor: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: pos.billStubPaper,
              border: Border(top: BorderSide(color: pos.billStubBorder)),
            ),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.amountDue,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  MoneyText(
                                    value: payableTotals.payableTotal.value,
                                    currency: currency,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontFamily: 'NotoSansThai',
                                          fontWeight: FontWeight.w800,
                                          height: 1.1,
                                        ),
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ],
                              ),
                            ),
                            if (hasBreakdown)
                              TextButton(
                                onPressed: () => setState(
                                  () => _expandedOverride = !expanded,
                                ),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      context.l10n.cartBillDetails,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Icon(
                                      expanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (expanded && hasBreakdown) ...[
                          const SizedBox(height: 8),
                          CartDottedLineRow(
                            label: context.l10n.receiptLabelSubtotal,
                            value: state.itemsSubtotal,
                            currency: currency,
                          ),
                          if (itemDiscountTotal > Money.zero) ...[
                            const SizedBox(height: 6),
                            CartDottedLineRow(
                              label: context.l10n.receiptItemDiscounts,
                              value: -itemDiscountTotal,
                              currency: currency,
                              valueColor: theme.colorScheme.error,
                            ),
                          ],
                          if (state.hasCartDiscount) ...[
                            const SizedBox(height: 6),
                            CartDottedLineRow(
                              label: context.l10n.cartDiscount,
                              value: -state.cartDiscountAmount,
                              currency: currency,
                              valueColor: theme.colorScheme.error,
                            ),
                          ],
                          if (hasPromo) ...[
                            const SizedBox(height: 6),
                            CartDottedLineRow(
                              label: context.l10n.receiptLabelPromotionDiscount,
                              value: -state.promotionDiscountMoney,
                              currency: currency,
                              valueColor: theme.colorScheme.error,
                            ),
                          ],
                          if (payableTotals.serviceChargeAmount >
                              Money.zero) ...[
                            const SizedBox(height: 6),
                            CartDottedLineRow(
                              label: context.l10n.serviceCharge,
                              value: payableTotals.serviceChargeAmount,
                              currency: currency,
                            ),
                          ],
                          if (payableTotals.vatAmount > Money.zero &&
                              !payableTotals.isVatInclusive) ...[
                            const SizedBox(height: 6),
                            CartDottedLineRow(
                              label:
                                  '${context.l10n.receiptLabelVat} ${payableTotals.vatRate}%',
                              value: payableTotals.vatAmount,
                              currency: currency,
                            ),
                          ],
                          if (payableTotals.vatAmount > Money.zero &&
                              payableTotals.isVatInclusive) ...[
                            const SizedBox(height: 6),
                            CartDottedLineRow(
                              label: context.l10n.receiptLabelVatIncluded(
                                payableTotals.vatRate.toStringAsFixed(0),
                              ),
                              value: payableTotals.vatAmount,
                              currency: currency,
                            ),
                          ],
                        ],
                        const SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stack = constraints.maxWidth < 420;
                            final park = OutlinedButton.icon(
                              key: const ValueKey('sale_cart_park_cta'),
                              onPressed: state.isEmpty
                                  ? null
                                  : () => DraftParkActions.parkCurrentBill(
                                      context,
                                    ),
                              onLongPress: state.isEmpty
                                  ? null
                                  : () => DraftParkActions.parkCurrentBill(
                                      context,
                                      promptForName: true,
                                    ),
                              icon: const Icon(
                                Icons.pause_circle_outline,
                                size: 20,
                              ),
                              label: Text(
                                context.l10n.parkBill,
                                style: const TextStyle(
                                  fontFamily: 'NotoSansThai',
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(
                                  stack ? double.infinity : 0,
                                  pos.ctaMinHeight,
                                ),
                                foregroundColor: pos.parkCtaForeground,
                                side: BorderSide(
                                  color: pos.parkCtaBorder.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                            );
                            final pay = FilledButton.icon(
                              key: const ValueKey('sale_cart_checkout_cta'),
                              onPressed: state.isEmpty
                                  ? null
                                  : () => navigateToCheckout(context),
                              icon: const Icon(
                                Icons.payments_outlined,
                                size: 22,
                              ),
                              label: Text(
                                context.l10n.payAmount(amountLabel),
                                style: const TextStyle(
                                  fontFamily: 'NotoSansThai',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                minimumSize: Size(
                                  stack ? double.infinity : 0,
                                  pos.ctaMinHeight,
                                ),
                                backgroundColor: pos.ctaFill,
                                foregroundColor: pos.ctaOnFill,
                                elevation: pos.elevPaperActive,
                                shadowColor: pos.ctaFill.withValues(
                                  alpha: pos.shadowFabCtaAlpha,
                                ),
                              ),
                            );
                            if (stack) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  park,
                                  const SizedBox(height: 8),
                                  pay,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(flex: 3, child: park),
                                const SizedBox(width: 10),
                                Expanded(flex: 5, child: pay),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
