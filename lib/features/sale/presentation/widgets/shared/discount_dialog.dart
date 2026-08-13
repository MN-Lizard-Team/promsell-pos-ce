import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';

/// Discount entry — ticket [PosBottomSheet] for **line item** and **bill**.
///
/// Legacy dialog path remains for direct widget tests (`asSheet: false`).
class DiscountDialog extends StatefulWidget {
  const DiscountDialog({
    super.key,
    required this.title,
    required this.currency,
    required this.initialType,
    required this.onApply,
    this.initialValue,
    this.onClear,
    this.maxPercent = 100.0,
    this.maxAmount = 0.0,
    this.presetValues = const [],
    this.presetType = 'PERCENT',
    this.asSheet = false,
    this.contextLine,
  });

  /// Sheet / dialog headline (e.g. cart discount or “Discount”).
  final String title;
  final String currency;
  final String initialType;
  final double? initialValue;
  final void Function(String type, double value) onApply;
  final VoidCallback? onClear;
  final double maxPercent;
  final double maxAmount;
  final List<double> presetValues;
  final String presetType;

  /// Ticket [PosBottomSheet] chrome (counter path).
  final bool asSheet;

  /// Optional product / line name under title (item discount).
  final String? contextLine;

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();

  /// Line-item discount — same ticket sheet as bill (not AlertDialog).
  static Future<void> showItemDiscount(
    BuildContext context, {
    required String title,
    required String currency,
    required String initialType,
    double? initialValue,
    required void Function(String, double) onApply,
    VoidCallback? onClear,
    double maxPercent = 100.0,
    double maxAmount = 0.0,
    List<double> presetValues = const [],
    String presetType = 'PERCENT',
  }) {
    final l10n = context.l10n;
    return PosBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.posTheme.billStubPaper,
      builder: (_) => DiscountDialog(
        title: l10n.discountDialogTitle,
        contextLine: title,
        currency: currency,
        initialType: initialType,
        initialValue: initialValue,
        onApply: onApply,
        onClear: onClear,
        maxPercent: maxPercent,
        maxAmount: maxAmount,
        presetValues: presetValues,
        presetType: presetType,
        asSheet: true,
      ),
    );
  }

  /// Cart / bill discount — keyboard-safe ticket sheet.
  static Future<void> showCartDiscount(
    BuildContext context, {
    required String title,
    required String currency,
    required String initialType,
    double? initialValue,
    required void Function(String, double) onApply,
    VoidCallback? onClear,
    double maxPercent = 100.0,
    double maxAmount = 0.0,
    List<double> presetValues = const [],
    String presetType = 'PERCENT',
  }) {
    return PosBottomSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.posTheme.billStubPaper,
      builder: (_) => DiscountDialog(
        title: title,
        currency: currency,
        initialType: initialType,
        initialValue: initialValue,
        onApply: onApply,
        onClear: onClear,
        maxPercent: maxPercent,
        maxAmount: maxAmount,
        presetValues: presetValues,
        presetType: presetType,
        asSheet: true,
      ),
    );
  }
}

class _DiscountDialogState extends State<DiscountDialog> {
  late String _type;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType == 'amount' ? 'amount' : 'PERCENT';
    final v = widget.initialValue;
    if (v != null && v > 0) {
      _ctrl.text = _type == 'PERCENT'
          ? v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)
          : v.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  void _close() {
    unfocusForDialogClose();
    Navigator.pop(context);
  }

  double get _rawValue => double.tryParse(_ctrl.text.replaceAll(',', '')) ?? 0;

  double get _effectiveValue {
    final value = _rawValue;
    if (_type == 'PERCENT') return value.clamp(0.0, widget.maxPercent);
    if (widget.maxAmount > 0) return value.clamp(0.0, widget.maxAmount);
    return value;
  }

  void _apply() {
    if (_rawValue <= 0) return;
    HapticFeedback.selectionClick();
    widget.onApply(_type, _effectiveValue);
    _close();
  }

  void _clear() {
    HapticFeedback.selectionClick();
    widget.onClear?.call();
    _close();
  }

  void _setType(String t) {
    if (_type == t) return;
    HapticFeedback.selectionClick();
    setState(() => _type = t);
  }

  void _pickPreset(double preset, {required bool asPercent}) {
    HapticFeedback.selectionClick();
    setState(() {
      _type = asPercent ? 'PERCENT' : 'AMOUNT';
      _ctrl.text = asPercent
          ? preset.toStringAsFixed(0)
          : preset.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.asSheet ? _buildSheet(context) : _buildDialog(context);
  }

  // --- Line item: compact dialog ---------------------------------------------

  Widget _buildDialog(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final value = _rawValue;

    return AlertDialog(
      title: Text(l10n.discountDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'PERCENT',
                label: Text(l10n.discountTypePercent),
              ),
              ButtonSegment(
                value: 'amount',
                label: Text(l10n.discountTypeAmount),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (v) => _setType(v.first),
          ),
          const SizedBox(height: 12),
          if (widget.presetValues.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.presetValues.map((preset) {
                final isPct = widget.presetType == 'PERCENT';
                final label = isPct
                    ? '${preset.toStringAsFixed(0)}%'
                    : '${widget.currency}${preset.toStringAsFixed(2)}';
                return ActionChip(
                  label: Text(label),
                  onPressed: () => _pickPreset(preset, asPercent: isPct),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: _type == 'PERCENT' ? '%' : widget.currency,
              border: const OutlineInputBorder(),
              helperText: _type == 'PERCENT'
                  ? '${l10n.maxDiscountPercent}: ${widget.maxPercent.toStringAsFixed(0)}%'
                  : widget.maxAmount > 0
                  ? '${l10n.maxDiscountAmount}: ${widget.currency}${widget.maxAmount.toStringAsFixed(2)}'
                  : null,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (value > 0) _apply();
            },
          ),
          if (value > 0) ...[
            const SizedBox(height: 8),
            Text(
              _type == 'PERCENT'
                  ? l10n.discountPreviewPercent(value.toStringAsFixed(0))
                  : l10n.discountPreview(
                      '${widget.currency}${value.toStringAsFixed(2)}',
                    ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (widget.onClear != null)
          TextButton(
            onPressed: _clear,
            child: Text(
              l10n.discountClear,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        TextButton(onPressed: _close, child: Text(l10n.cancel)),
        FilledButton(
          onPressed: value > 0 ? _apply : null,
          child: Text(l10n.discountApply),
        ),
      ],
    );
  }

  // --- Bill sheet: POS counter — field first, type toggle, presets, footer --

  Widget _buildSheet(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    final value = _rawValue;
    final isPercent = _type == 'PERCENT';
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canApply = value > 0;

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
              // 1) Title (+ optional line context for item discount).
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title.isNotEmpty
                              ? widget.title
                              : l10n.cartDiscount,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (widget.contextLine != null &&
                            widget.contextLine!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.contextLine!.trim(),
                            key: const ValueKey('discount_sheet_context'),
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
                    key: const ValueKey('bill_discount_close'),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: _close,
                    icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2) Primary: big value field (cashier numpad path).
              TextField(
                key: const ValueKey('bill_discount_value'),
                controller: _ctrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFamily: 'NotoSansThai',
                  height: 1.15,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  hintText: isPercent ? '0' : '0.00',
                  prefixText: isPercent ? null : '${widget.currency} ',
                  suffixText: isPercent ? ' %' : null,
                  prefixStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                  suffixStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
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
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (canApply) _apply();
                },
              ),
              const SizedBox(height: 10),

              // 3) Type toggle under field — short labels, equal width.
              Row(
                children: [
                  Expanded(
                    child: _SheetToggle(
                      key: const ValueKey('bill_discount_type_percent'),
                      selected: isPercent,
                      label: '%',
                      onTap: () => _setType('PERCENT'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SheetToggle(
                      key: const ValueKey('bill_discount_type_amount'),
                      selected: !isPercent,
                      label: widget.currency,
                      onTap: () => _setType('AMOUNT'),
                    ),
                  ),
                ],
              ),

              // 4) Quick presets (optional).
              if (widget.presetValues.isNotEmpty) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.presetValues.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final preset = widget.presetValues[i];
                      final isPct = widget.presetType == 'PERCENT';
                      final label = isPct
                          ? '${preset.toStringAsFixed(0)}%'
                          : '${widget.currency}${preset.toStringAsFixed(0)}';
                      final selected =
                          isPct == isPercent &&
                          (_rawValue - preset).abs() < 0.001;
                      return _SheetToggle(
                        selected: selected,
                        label: label,
                        compact: true,
                        onTap: () => _pickPreset(preset, asPercent: isPct),
                      );
                    },
                  ),
                ),
              ],

              // 5) Live preview — one line, no heavy card.
              if (canApply) ...[
                const SizedBox(height: 12),
                Text(
                  isPercent
                      ? l10n.discountPreviewPercent(
                          value.toStringAsFixed(
                            value == value.roundToDouble() ? 0 : 1,
                          ),
                        )
                      : l10n.discountPreview(
                          '${widget.currency}${value.toStringAsFixed(2)}',
                        ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: pos.parkCtaForeground,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 6) Actions: primary Apply full width; secondary row clear/cancel.
              FilledButton(
                key: const ValueKey('bill_discount_apply'),
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
                onPressed: canApply ? _apply : null,
                child: Text(
                  l10n.discountApply,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.onClear != null)
                    Expanded(
                      child: TextButton(
                        key: const ValueKey('bill_discount_clear'),
                        onPressed: _clear,
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.error,
                          minimumSize: Size(0, pos.ctaMinHeight * 0.75),
                        ),
                        child: Text(
                          l10n.discountClear,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  Expanded(
                    child: TextButton(
                      key: const ValueKey('bill_discount_cancel'),
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

/// Paper toggle / preset chip for bill discount sheet.
class _SheetToggle extends StatelessWidget {
  const _SheetToggle({
    super.key,
    required this.selected,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final scheme = theme.colorScheme;
    final h = compact ? 40.0 : 44.0;

    return Material(
      color: selected
          ? pos.parkCtaForeground.withValues(alpha: 0.12)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pos.billStubRadius),
        side: BorderSide(
          color: selected ? pos.parkCtaForeground : pos.billStubBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(pos.billStubRadius),
        child: SizedBox(
          height: h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 8),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? pos.parkCtaForeground
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
