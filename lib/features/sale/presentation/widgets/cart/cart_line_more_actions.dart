import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';

/// Cart line overflow — ticket chip + compact [PosBottomSheet] (DraftTile dialect).
///
/// Opened from the more chip or **long-press** on the row ([show]).
class CartLineMoreActions extends StatelessWidget {
  const CartLineMoreActions({
    super.key,
    required this.enableDiscount,
    required this.onDiscount,
    required this.onNote,
    required this.onDuplicate,
    required this.onRemove,
    this.item,
    this.currency,
  });

  final bool enableDiscount;
  final VoidCallback onDiscount;
  final VoidCallback onNote;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  /// Line context for sheet header + unique finder key.
  final CartItem? item;
  final String? currency;

  /// Open line actions sheet (more chip or long-press).
  static Future<void> show(
    BuildContext context, {
    required bool enableDiscount,
    required VoidCallback onDiscount,
    required VoidCallback onNote,
    required VoidCallback onDuplicate,
    required VoidCallback onRemove,
    CartItem? item,
    String? currency,
  }) async {
    HapticFeedback.mediumImpact();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final scheme = theme.colorScheme;

    // Compact action sheet — content-sized, not a tall empty frame.
    // Matches DraftTile more sheet: simple header + dense rows + billStub paper.
    await PosBottomSheet.show<void>(
      context: context,
      backgroundColor: pos.billStubPaper,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 20,
                          color: pos.activeBillRail,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: 'NotoSansThai',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (currency != null) ...[
                          Text(
                            '×${item.qty}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          MoneyText(
                            value: item.subtotal.value,
                            currency: currency,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'NotoSansThai',
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Divider(height: 1, color: pos.billStubBorder),
                  const SizedBox(height: 4),
                ],
                if (enableDiscount)
                  _ActionTile(
                    icon: Icons.local_offer_outlined,
                    label: l10n.discountSectionLabel,
                    onTap: () {
                      Navigator.pop(ctx);
                      onDiscount();
                    },
                  ),
                _ActionTile(
                  icon: Icons.note_alt_outlined,
                  label: l10n.itemNoteLabel,
                  onTap: () {
                    Navigator.pop(ctx);
                    onNote();
                  },
                ),
                _ActionTile(
                  icon: Icons.copy_outlined,
                  label: l10n.duplicateItemAction,
                  onTap: () {
                    Navigator.pop(ctx);
                    onDuplicate();
                  },
                ),
                const SizedBox(height: 4),
                Divider(height: 1, color: pos.billStubBorder),
                const SizedBox(height: 4),
                _ActionTile(
                  icon: Icons.delete_outline,
                  label: l10n.delete,
                  destructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    onRemove();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSheet(BuildContext context) => show(
    context,
    enableDiscount: enableDiscount,
    onDiscount: onDiscount,
    onNote: onNote,
    onDuplicate: onDuplicate,
    onRemove: onRemove,
    item: item,
    currency: currency,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final lineKey = item != null
        ? ValueKey('sale_cart_line_more_${item!.lineId}')
        : const ValueKey('sale_cart_line_more');
    final tooltip = MaterialLocalizations.of(context).moreButtonTooltip;

    // Ticket chip — same dialect as qty stepper (paper + billStubBorder).
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 2),
      child: Material(
        key: lineKey,
        color: pos.billStubPaper,
        elevation: pos.elevFlat,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: pos.billStubBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: () => _openSheet(context),
            child: Semantics(
              button: true,
              label: tooltip,
              child: SizedBox(
                width: 36,
                height: 34,
                child: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dense action row — matches DraftTile more sheet (no icon wells / chevrons).
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'NotoSansThai',
                    fontWeight: FontWeight.w700,
                    color: color,
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
