import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/pos_bill_name_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Open-bill **receipt ticket** row for the bills board.
///
/// Color language: white paper + teal rail only. Orange = Pay. No mint wash.
class DraftTile extends StatelessWidget {
  const DraftTile({
    super.key,
    required this.id,
    required this.name,
    required this.itemCount,
    required this.total,
    required this.currency,
    required this.isActive,
    this.updatedAt,
    this.tableId,
    this.note,
    this.previewItemName,
    this.orderChannel,
    required this.l10n,
    required this.theme,
    required this.onSwitch,
    required this.onDelete,
    required this.onRename,
    this.onPay,
  });

  final String id;
  final String? name;
  final int itemCount;
  final double total;
  final String currency;
  final bool isActive;
  final DateTime? updatedAt;
  final String? tableId;
  final String? note;
  final String? previewItemName;
  final String? orderChannel;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback? onSwitch;
  final VoidCallback? onDelete;
  final void Function(String)? onRename;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final pos = context.posTheme;
    final scheme = theme.colorScheme;
    final displayName = name?.isNotEmpty == true ? name! : l10n.untitledDraft;
    final overdue =
        updatedAt != null && DateTime.now().difference(updatedAt!).inHours >= 2;
    final age = updatedAt != null ? _timeAgo(updatedAt!) : null;

    final chips = <Widget>[
      if (tableId != null && tableId!.trim().isNotEmpty)
        _MetaChip(
          icon: Icons.table_restaurant_outlined,
          label: tableId!.trim(),
          pos: pos,
          theme: theme,
          emphasize: true,
        ),
      if (previewItemName != null && previewItemName!.trim().isNotEmpty)
        _MetaChip(
          icon: Icons.shopping_bag_outlined,
          label: previewItemName!.trim(),
          pos: pos,
          theme: theme,
          maxWidth: 128,
        ),
      if (note != null && note!.trim().isNotEmpty)
        _MetaChip(
          icon: Icons.sticky_note_2_outlined,
          label: note!.trim(),
          pos: pos,
          theme: theme,
          maxWidth: 110,
        ),
      if (orderChannel != null &&
          orderChannel!.trim().isNotEmpty &&
          orderChannel != 'walkin')
        _MetaChip(
          icon: Icons.storefront_outlined,
          label: orderChannel!.trim(),
          pos: pos,
          theme: theme,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        key: ValueKey('sale_bill_tile_$id'),
        color: Colors.transparent,
        // Paper ladder — active uses elevPaperActive; rail/border still primary cue.
        elevation: isActive ? pos.elevPaperActive : pos.elevPaper,
        shadowColor: pos.shadowKey.withValues(
          alpha: isActive ? pos.shadowDockFarAlpha : pos.shadowDockNearAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(pos.billStubRadius),
        child: InkWell(
          onTap: onSwitch,
          onLongPress: onRename != null
              ? () => _showRenameSheet(context, name ?? '')
              : null,
          borderRadius: BorderRadius.circular(pos.billStubRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: isActive ? pos.activeBillFill : pos.billStubPaper,
              borderRadius: BorderRadius.circular(pos.billStubRadius),
              border: Border.all(
                color: isActive ? pos.activeBillRail : pos.billStubBorder,
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: pos.billRowMinHeight + 8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ticket rail only — teal on active, neutral on parked.
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? pos.activeBillRail
                            : pos.billStubBorder,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            pos.billStubRadius > 0 ? pos.billStubRadius - 1 : 0,
                          ),
                          bottomLeft: Radius.circular(
                            pos.billStubRadius > 0 ? pos.billStubRadius - 1 : 0,
                          ),
                        ),
                      ),
                    ),
                    // Body.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      // Always ink-on-paper — not teal wash.
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isActive) ...[
                                  const SizedBox(width: 8),
                                  _LiveBadge(
                                    l10n: l10n,
                                    pos: pos,
                                    theme: theme,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 13,
                                  color: overdue
                                      ? scheme.error
                                      : scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    [
                                      '$itemCount ${l10n.itemsLabel}',
                                      ?age,
                                    ].join(' · '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: overdue
                                          ? scheme.error
                                          : scheme.onSurfaceVariant,
                                      fontWeight: overdue
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (chips.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(spacing: 6, runSpacing: 5, children: chips),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Soft money column (neutral wash, not teal).
                    Container(
                      constraints: const BoxConstraints(minWidth: 108),
                      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(
                          alpha: 0.18,
                        ),
                        border: Border(
                          left: BorderSide(
                            color: pos.billStubBorder.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.amountDue,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          MoneyText(
                            value: total,
                            currency: currency,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'NotoSansThai',
                              height: 1.05,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onPay != null && itemCount > 0)
                                FilledButton(
                                  key: ValueKey('sale_bill_tile_pay_$id'),
                                  onPressed: onPay,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: pos.ctaFill,
                                    foregroundColor: pos.ctaOnFill,
                                    elevation: 0,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    minimumSize: const Size(0, 34),
                                    // Button radius stays even when ticket is square.
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.payments_outlined,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.checkoutButton,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (onRename != null || onDelete != null)
                                IconButton(
                                  key: ValueKey('sale_bill_tile_more_$id'),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                  tooltip: MaterialLocalizations.of(
                                    context,
                                  ).moreButtonTooltip,
                                  onPressed: () => _openMoreSheet(
                                    context,
                                    displayName: displayName,
                                  ),
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 20,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return l10n.timeAgoDays(diff.inDays);
    if (diff.inHours > 0) return l10n.timeAgoHours(diff.inHours);
    if (diff.inMinutes > 0) return l10n.timeAgoMinutes(diff.inMinutes);
    return l10n.justNow;
  }

  /// ⋮ → bottom sheet actions (rename / delete) — not PopupMenu.
  Future<void> _openMoreSheet(
    BuildContext context, {
    required String displayName,
  }) async {
    HapticFeedback.selectionClick();
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final scheme = theme.colorScheme;

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: pos.activeBillRail,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (itemCount > 0)
                        MoneyText(
                          value: total,
                          currency: currency,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'NotoSansThai',
                            color: scheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: pos.billStubBorder),
                const SizedBox(height: 4),
                if (onRename != null)
                  _BillMoreActionTile(
                    key: ValueKey('sale_bill_more_rename_$id'),
                    icon: Icons.edit_outlined,
                    label: l10n.renameDraft,
                    onTap: () {
                      Navigator.pop(ctx);
                      // Prefill raw name — not untitled l10n (avoids saving "Untitled bill").
                      _showRenameSheet(context, name ?? '');
                    },
                  ),
                if (onDelete != null) ...[
                  if (onRename != null) ...[
                    const SizedBox(height: 4),
                    Divider(height: 1, color: pos.billStubBorder),
                    const SizedBox(height: 4),
                  ],
                  _BillMoreActionTile(
                    key: ValueKey('sale_bill_more_delete_$id'),
                    icon: Icons.delete_outline,
                    label: l10n.deleteDraft,
                    destructive: true,
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDelete(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRenameSheet(BuildContext context, String current) async {
    final name = await PosBillNameDialog.show(
      context,
      title: l10n.renameDraft,
      hint: l10n.draftNameHint,
      initialName: current,
      confirmLabel: l10n.save,
      contextLine: itemCount > 0
          ? '$itemCount ${l10n.itemsLabel} · $currency${total.toStringAsFixed(total == total.roundToDouble() ? 0 : 2)}'
          : null,
    );
    if (name != null) onRename?.call(name);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showAppConfirm(
      context,
      title: l10n.deleteDraft,
      message: l10n.deleteDraftConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (ok && context.mounted) onDelete?.call();
  }
}

class _BillMoreActionTile extends StatelessWidget {
  const _BillMoreActionTile({
    super.key,
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

/// Outline live pill — teal border + ink, orange pulse only.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge({
    required this.l10n,
    required this.pos,
    required this.theme,
  });

  final AppLocalizations l10n;
  final PosThemeExtension pos;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: pos.billStubPaper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pos.activeBillRail, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: pos.ctaFill,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            l10n.activeDraftLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: pos.activeBillRail,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.pos,
    required this.theme,
    this.maxWidth = 140,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final PosThemeExtension pos;
  final ThemeData theme;
  final double maxWidth;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    // Neutral paper chips — table gets slightly stronger border only.
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: emphasize
              ? pos.activeBillRail.withValues(alpha: 0.45)
              : pos.billStubBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: emphasize ? pos.activeBillRail : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: emphasize ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
