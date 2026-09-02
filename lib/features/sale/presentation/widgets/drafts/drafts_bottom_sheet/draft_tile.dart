import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/services/restaurant_table_name_resolver.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/draft_naming.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/pos_bill_name_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Open-bill **receipt ticket** row for the bills board.
///
/// Color language: white paper + teal rail only. Orange = Pay. No mint wash.
class DraftTile extends StatefulWidget {
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
  State<DraftTile> createState() => _DraftTileState();
}

class _DraftTileState extends State<DraftTile> {
  /// Resolved name for [DraftTile.tableId] — null while pending or when the
  /// table was deleted (title/chip then fall back to a short id).
  String? _tableName;

  @override
  void initState() {
    super.initState();
    _resolveTable();
  }

  @override
  void didUpdateWidget(covariant DraftTile old) {
    super.didUpdateWidget(old);
    if (old.tableId != widget.tableId) _resolveTable();
  }

  Future<void> _resolveTable() async {
    final id = widget.tableId?.trim();
    if (id == null || id.isEmpty) return;
    final name = await sl<RestaurantTableNameResolver>().resolve(id);
    if (!mounted) return;
    setState(() => _tableName = name);
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.posTheme;
    final theme = widget.theme;
    final l10n = widget.l10n;
    final scheme = theme.colorScheme;
    final rawName = widget.name?.isNotEmpty == true
        ? widget.name!
        : l10n.untitledDraft;
    final tableId = widget.tableId?.trim();
    // Bills parked against a table carry the raw tableId as their name —
    // show the resolved table name (or short id) instead of the UUID.
    final autoNamedFromTable =
        tableId != null && tableId.isNotEmpty && rawName == tableId;
    final displayName = autoNamedFromTable
        ? (_tableName ?? DraftNaming.shortTableRef(tableId))
        : rawName;
    final overdue =
        widget.updatedAt != null &&
        DateTime.now().difference(widget.updatedAt!).inHours >= 2;
    final age = widget.updatedAt != null ? _timeAgo(widget.updatedAt!) : null;

    final chips = <Widget>[
      if (tableId != null && tableId.isNotEmpty)
        _MetaChip(
          icon: Icons.table_restaurant_outlined,
          label: l10n.tableChipLabel(
            _tableName ?? DraftNaming.shortTableRef(tableId),
          ),
          pos: pos,
          theme: theme,
          emphasize: true,
        ),
      if (widget.previewItemName != null &&
          widget.previewItemName!.trim().isNotEmpty)
        _MetaChip(
          icon: Icons.shopping_bag_outlined,
          label: widget.previewItemName!.trim(),
          pos: pos,
          theme: theme,
          maxWidth: 128,
        ),
      if (widget.note != null && widget.note!.trim().isNotEmpty)
        _MetaChip(
          icon: Icons.sticky_note_2_outlined,
          label: widget.note!.trim(),
          pos: pos,
          theme: theme,
          maxWidth: 110,
        ),
      if (widget.orderChannel != null &&
          widget.orderChannel!.trim().isNotEmpty &&
          widget.orderChannel != 'walkin')
        _MetaChip(
          icon: Icons.storefront_outlined,
          label: widget.orderChannel!.trim(),
          pos: pos,
          theme: theme,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        key: ValueKey('sale_bill_tile_${widget.id}'),
        color: Colors.transparent,
        // Paper ladder — active uses elevPaperActive; rail/border still primary cue.
        elevation: widget.isActive ? pos.elevPaperActive : pos.elevPaper,
        shadowColor: pos.shadowKey.withValues(
          alpha: widget.isActive
              ? pos.shadowDockFarAlpha
              : pos.shadowDockNearAlpha,
        ),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(pos.billStubRadius),
        child: InkWell(
          onTap: widget.onSwitch,
          onLongPress: widget.onRename != null
              ? () => _showRenameSheet(context, widget.name ?? '')
              : null,
          borderRadius: BorderRadius.circular(pos.billStubRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: widget.isActive ? pos.activeBillFill : pos.billStubPaper,
              borderRadius: BorderRadius.circular(pos.billStubRadius),
              border: Border.all(
                color: widget.isActive
                    ? pos.activeBillRail
                    : pos.billStubBorder,
                width: widget.isActive ? 1.5 : 1,
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
                        color: widget.isActive
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
                                if (widget.isActive) ...[
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
                                      '${widget.itemCount} ${l10n.itemsLabel}',
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
                            value: widget.total,
                            currency: widget.currency,
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
                              if (widget.onPay != null && widget.itemCount > 0)
                                FilledButton(
                                  key: ValueKey(
                                    'sale_bill_tile_pay_${widget.id}',
                                  ),
                                  onPressed: widget.onPay,
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
                              if (widget.onRename != null ||
                                  widget.onDelete != null)
                                IconButton(
                                  key: ValueKey(
                                    'sale_bill_tile_more_${widget.id}',
                                  ),
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
    if (diff.inDays > 0) return widget.l10n.timeAgoDays(diff.inDays);
    if (diff.inHours > 0) return widget.l10n.timeAgoHours(diff.inHours);
    if (diff.inMinutes > 0) return widget.l10n.timeAgoMinutes(diff.inMinutes);
    return widget.l10n.justNow;
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
                      if (widget.itemCount > 0)
                        MoneyText(
                          value: widget.total,
                          currency: widget.currency,
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
                if (widget.onRename != null)
                  _BillMoreActionTile(
                    key: ValueKey('sale_bill_more_rename_${widget.id}'),
                    icon: Icons.edit_outlined,
                    label: widget.l10n.renameDraft,
                    onTap: () {
                      Navigator.pop(ctx);
                      // Prefill raw name — not untitled l10n (avoids saving "Untitled bill").
                      _showRenameSheet(context, widget.name ?? '');
                    },
                  ),
                if (widget.onDelete != null) ...[
                  if (widget.onRename != null) ...[
                    const SizedBox(height: 4),
                    Divider(height: 1, color: pos.billStubBorder),
                    const SizedBox(height: 4),
                  ],
                  _BillMoreActionTile(
                    key: ValueKey('sale_bill_more_delete_${widget.id}'),
                    icon: Icons.delete_outline,
                    label: widget.l10n.deleteDraft,
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
      title: widget.l10n.renameDraft,
      hint: widget.l10n.draftNameHint,
      initialName: current,
      confirmLabel: widget.l10n.save,
      contextLine: widget.itemCount > 0
          ? '${widget.itemCount} ${widget.l10n.itemsLabel} · ${widget.currency}${widget.total.toStringAsFixed(widget.total == widget.total.roundToDouble() ? 0 : 2)}'
          : null,
    );
    if (name != null) widget.onRename?.call(name);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showAppConfirm(
      context,
      title: widget.l10n.deleteDraft,
      message: widget.l10n.deleteDraftConfirm,
      confirmLabel: widget.l10n.delete,
      cancelLabel: widget.l10n.cancel,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (ok && context.mounted) widget.onDelete?.call();
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
