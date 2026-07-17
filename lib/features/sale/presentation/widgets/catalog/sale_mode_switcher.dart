import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_park_actions.dart';

/// Bill status strip: current bill | open bills | park (1-tap).
class SaleModeSwitcher extends StatelessWidget {
  const SaleModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              buildWhen: (p, c) => p.itemCount != c.itemCount,
              builder: (context, cart) {
                return BlocBuilder<DraftBloc, DraftState>(
                  buildWhen: (p, c) =>
                      p.activeDraftName != c.activeDraftName ||
                      p.activeDraftId != c.activeDraftId,
                  builder: (context, draft) {
                    final name = draft.activeDraftName?.trim();
                    final String label;
                    if (name != null && name.isNotEmpty) {
                      label = l10n.currentBillNamed(name, cart.itemCount);
                    } else if (cart.itemCount > 0) {
                      label = l10n.currentBillWithCount(cart.itemCount);
                    } else {
                      label = l10n.currentBill;
                    }
                    return _ModeChip(
                      emphasized: true,
                      icon: Icons.receipt_long_outlined,
                      label: label,
                      onTap: () => openCartReviewPage(context),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BlocBuilder<DraftBloc, DraftState>(
              buildWhen: (p, c) =>
                  p.openBillCount != c.openBillCount ||
                  p.draftCount != c.draftCount,
              builder: (context, draft) {
                final n = draft.openBillCount;
                final label = n > 0 ? l10n.openBillsCount(n) : l10n.draftsTitle;
                return _ModeChip(
                  emphasized: false,
                  icon: Icons.folder_copy_outlined,
                  label: label,
                  onTap: () => SavedBillsPage.open(context),
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) => p.isEmpty != c.isEmpty,
            builder: (context, cart) {
              return BlocBuilder<DraftBloc, DraftState>(
                buildWhen: (p, c) => p.opStatus != c.opStatus,
                builder: (context, draft) {
                  final enabled = !cart.isEmpty && !draft.isBusy;
                  return Material(
                    color: enabled
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      key: const ValueKey('sale_catalog_park_cta'),
                      tooltip: l10n.parkAndNext,
                      onPressed: enabled
                          ? () => DraftParkActions.parkCurrentBill(context)
                          : null,
                      onLongPress: enabled
                          ? () => DraftParkActions.parkCurrentBill(
                              context,
                              promptForName: true,
                            )
                          : null,
                      icon: Icon(
                        Icons.pause_circle_outline,
                        color: enabled
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.emphasized,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool emphasized;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = emphasized
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;
    final fg = emphasized
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.primary;
    final border = emphasized
        ? BorderSide.none
        : BorderSide(color: theme.colorScheme.outlineVariant);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: border,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansThai',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
