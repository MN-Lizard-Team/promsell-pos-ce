import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';

/// Bill name entry — **bottom sheet** (not a centered dialog).
///
/// Used from Park long-press, Open bills +, rename tile.
/// Confirm = teal settle (never orange — orange is Pay only).
///
/// Filename kept for import stability; presentation is [PosBottomSheet].
class PosBillNameDialog {
  PosBillNameDialog._();

  /// Returns trimmed name, or `null` if cancelled. Empty string = leave blank / auto.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hint,
    required String confirmLabel,
    String initialName = '',
    String? contextLine,
  }) {
    return PosBottomSheet.show<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.posTheme.billStubPaper,
      builder: (ctx) => _PosBillNameSheet(
        title: title,
        hint: hint,
        confirmLabel: confirmLabel,
        initialName: initialName,
        contextLine: contextLine,
      ),
    );
  }
}

class _PosBillNameSheet extends StatefulWidget {
  const _PosBillNameSheet({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    this.initialName = '',
    this.contextLine,
  });

  final String title;
  final String hint;
  final String confirmLabel;
  final String initialName;
  final String? contextLine;

  @override
  State<_PosBillNameSheet> createState() => _PosBillNameSheetState();
}

class _PosBillNameSheetState extends State<_PosBillNameSheet> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  static const int _maxLen = 40;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
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

  void _submit() => Navigator.pop(context, _ctrl.text.trim());

  void _cancel() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    final hasContext =
        widget.contextLine != null && widget.contextLine!.trim().isNotEmpty;
    final charCount = _ctrl.text.length;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: pos.parkCtaForeground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: pos.parkCtaForeground,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.hint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: _cancel,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (hasContext) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.22,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: pos.billStubBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: pos.parkCtaForeground,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.contextLine!.trim(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                focusNode: _focus,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                maxLength: _maxLen,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  counterText: '',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.18,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: pos.billStubBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: pos.billStubBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: pos.parkCtaForeground,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$charCount/$_maxLen',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: charCount >= _maxLen
                        ? scheme.error
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                        side: BorderSide(color: pos.billStubBorder),
                        minimumSize: Size(0, pos.ctaMinHeight * 0.82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: pos.parkCtaForeground,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(0, pos.ctaMinHeight * 0.82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        widget.confirmLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
