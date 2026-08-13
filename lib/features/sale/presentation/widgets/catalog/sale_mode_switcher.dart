import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_park_actions.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Compact multi-bill bar on sale catalog.
///
/// One paper band: **current bill** (teal rail) | open count | **Park**.
/// Other bills: open-count → Saved Bills (no horizontal ticket strip).
class SaleModeSwitcher extends StatelessWidget {
  const SaleModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 6),
      child: Material(
        color: pos.billStubPaper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: pos.billStubBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              // Current bill — primary surface with ticket rail.
              Expanded(
                child: BlocBuilder<CartBloc, CartState>(
                  buildWhen: (p, c) =>
                      p.itemCount != c.itemCount ||
                      p.itemsSubtotal != c.itemsSubtotal ||
                      p.cartDiscountAmount != c.cartDiscountAmount ||
                      p.promotionDiscountAmount != c.promotionDiscountAmount ||
                      p.serviceChargeRate != c.serviceChargeRate,
                  builder: (context, cart) {
                    return BlocBuilder<DraftBloc, DraftState>(
                      buildWhen: (p, c) =>
                          p.activeDraftName != c.activeDraftName ||
                          p.activeDraftId != c.activeDraftId,
                      builder: (context, draft) {
                        final name = draft.activeDraftName?.trim();
                        final title = (name != null && name.isNotEmpty)
                            ? name
                            : l10n.currentBill;
                        final settings = context
                            .read<SettingsCubit>()
                            .state
                            .settings;
                        final due = cart.payableTotals(settings).payableTotal;

                        return InkWell(
                          key: const ValueKey('sale_catalog_current_bill'),
                          onTap: () => openCartReviewPage(context),
                          child: Row(
                            children: [
                              Container(width: 3.5, color: pos.activeBillRail),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                            ),
                                            Text(
                                              l10n.cartItemCount(
                                                cart.itemCount,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (cart.itemCount > 0) ...[
                                        const SizedBox(width: 6),
                                        MoneyText(
                                          value: due.value,
                                          currency: currency,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'NotoSansThai',
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                      Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                        color: theme
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.55),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: pos.billStubBorder,
              ),
              // Open bills — icon + count only (tap → SavedBillsPage).
              BlocBuilder<DraftBloc, DraftState>(
                buildWhen: (p, c) =>
                    p.openBillCount != c.openBillCount ||
                    p.draftCount != c.draftCount,
                builder: (context, draft) {
                  final n = draft.openBillCount;
                  return Tooltip(
                    message: l10n.openBillsCount(n),
                    child: InkWell(
                      key: const ValueKey('sale_catalog_open_bills'),
                      onTap: () => SavedBillsPage.open(context),
                      child: SizedBox(
                        width: 52,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open_outlined,
                              size: 18,
                              color: pos.activeBillRail,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$n',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: pos.activeBillRail,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: pos.billStubBorder,
              ),
              // Park — outline teal, never orange.
              BlocBuilder<CartBloc, CartState>(
                buildWhen: (p, c) => p.isEmpty != c.isEmpty,
                builder: (context, cart) {
                  return BlocBuilder<DraftBloc, DraftState>(
                    buildWhen: (p, c) => p.opStatus != c.opStatus,
                    builder: (context, draft) {
                      final enabled = !cart.isEmpty && !draft.isBusy;
                      final muted = theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.45);
                      return Tooltip(
                        message: l10n.parkBill,
                        child: InkWell(
                          key: const ValueKey('sale_catalog_park_cta'),
                          onTap: enabled
                              ? () {
                                  HapticFeedback.selectionClick();
                                  DraftParkActions.parkCurrentBill(context);
                                }
                              : null,
                          onLongPress: enabled
                              ? () => DraftParkActions.parkCurrentBill(
                                  context,
                                  promptForName: true,
                                )
                              : null,
                          child: SizedBox(
                            width: 52,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pause_circle_outline,
                                  size: 18,
                                  color: enabled
                                      ? pos.parkCtaForeground
                                      : muted,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.parkBill,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    height: 1,
                                    color: enabled
                                        ? pos.parkCtaForeground
                                        : muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
