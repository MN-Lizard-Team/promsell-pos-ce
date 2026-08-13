import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';

/// Note entry — ticket [PosBottomSheet] for **bill** or **line item**.
///
/// Layout: title (+ optional context line) + field first, clear/save footer.
class BillNoteSheet extends StatefulWidget {
  const BillNoteSheet({
    super.key,
    required this.initialValue,
    required this.onSave,
    this.maxLength = 200,
    this.title,
    this.contextLine,
  });

  final String initialValue;
  final ValueChanged<String> onSave;
  final int maxLength;

  /// Defaults to bill note title when null.
  final String? title;

  /// Optional product / line name under title (item note).
  final String? contextLine;

  /// Cart / bill note.
  static Future<void> show(
    BuildContext context, {
    required String initialValue,
    required ValueChanged<String> onSave,
    int maxLength = 200,
    String? title,
    String? contextLine,
  }) {
    return PosBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.posTheme.billStubPaper,
      builder: (_) => BillNoteSheet(
        initialValue: initialValue,
        onSave: onSave,
        maxLength: maxLength,
        title: title,
        contextLine: contextLine,
      ),
    );
  }

  /// Line-item note (from cart more / detail).
  static Future<void> showItemNote(
    BuildContext context, {
    required String productName,
    required String initialValue,
    required ValueChanged<String> onSave,
    int maxLength = 200,
  }) {
    return show(
      context,
      initialValue: initialValue,
      onSave: onSave,
      maxLength: maxLength,
      title: context.l10n.itemNoteLabel,
      contextLine: productName,
    );
  }

  @override
  State<BillNoteSheet> createState() => _BillNoteSheetState();
}

class _BillNoteSheetState extends State<BillNoteSheet> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _focus = FocusNode();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  String get _trimmed => _ctrl.text.trim();
  bool get _hasText => _trimmed.isNotEmpty;

  void _close() {
    unfocusForDialogClose();
    Navigator.pop(context);
  }

  void _save() {
    HapticFeedback.selectionClick();
    widget.onSave(_trimmed);
    _close();
  }

  void _clear() {
    HapticFeedback.selectionClick();
    _ctrl.clear();
    // Keep focus so cashier can retype immediately.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final count = _ctrl.text.characters.length;
    final over = count > widget.maxLength;
    final headline = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : l10n.saleBillNoteTitle;
    final contextLine = widget.contextLine?.trim();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1) Title + close (+ optional line context)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headline,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (contextLine != null && contextLine.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            contextLine,
                            key: const ValueKey('note_sheet_context'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('bill_note_close'),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: _close,
                    icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2) Multi-line field first (keyboard path)
              TextField(
                key: const ValueKey('bill_note_field'),
                controller: _ctrl,
                focusNode: _focus,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: widget.maxLength,
                textInputAction: TextInputAction.newline,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NotoSansThai',
                  height: 1.35,
                ),
                decoration: InputDecoration(
                  hintText: l10n.notePlaceholder,
                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  counterText: '$count / ${widget.maxLength}',
                  counterStyle: theme.textTheme.labelSmall?.copyWith(
                    color: over ? scheme.error : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(pos.billStubRadius),
                    borderSide: BorderSide(color: pos.billStubBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(pos.billStubRadius),
                    borderSide: BorderSide(color: pos.billStubBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(pos.billStubRadius),
                    borderSide: BorderSide(
                      color: pos.parkCtaForeground,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3) Primary save full width
              FilledButton(
                key: const ValueKey('bill_note_save'),
                style: FilledButton.styleFrom(
                  backgroundColor: pos.parkCtaForeground,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: scheme.surfaceContainerHighest,
                  elevation: 0,
                  minimumSize: Size.fromHeight(pos.ctaMinHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: over ? null : _save,
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 4) Secondary: clear (if text) + cancel
              Row(
                children: [
                  if (_hasText || widget.initialValue.trim().isNotEmpty)
                    Expanded(
                      child: TextButton(
                        key: const ValueKey('bill_note_clear'),
                        onPressed: _clear,
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.error,
                          minimumSize: Size(0, pos.ctaMinHeight * 0.75),
                        ),
                        child: Text(
                          l10n.clear,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TextButton(
                      key: const ValueKey('bill_note_cancel'),
                      onPressed: _close,
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                        minimumSize: Size(0, pos.ctaMinHeight * 0.75),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
