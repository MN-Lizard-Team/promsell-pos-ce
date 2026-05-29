import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

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
  });

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

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();

  static void showItemDiscount(
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
    showDialog(
      context: context,
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
      ),
    );
  }

  static void showCartDiscount(
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
    showDialog(
      context: context,
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
    _type = widget.initialType;
    _ctrl.text = widget.initialValue?.toStringAsFixed(2) ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final value = double.tryParse(_ctrl.text) ?? 0;

    return AlertDialog(
      title: Text(l10n.discountDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
                value: 'AMOUNT',
                label: Text(l10n.discountTypeAmount),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
          ),
          const SizedBox(height: 12),
          if (widget.presetValues.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.presetValues.map((preset) {
                final isPresetPercent = widget.presetType == 'PERCENT';
                final label = isPresetPercent
                    ? '${preset.toStringAsFixed(0)}%'
                    : '${widget.currency}${preset.toStringAsFixed(2)}';
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    _ctrl.text = preset.toStringAsFixed(
                      isPresetPercent ? 0 : 2,
                    );
                    if (isPresetPercent) {
                      setState(() => _type = 'PERCENT');
                    } else {
                      setState(() => _type = 'AMOUNT');
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _type == 'PERCENT' ? '%' : widget.currency,
              border: const OutlineInputBorder(),
              helperText: _type == 'PERCENT'
                  ? '${context.l10n.maxDiscountPercent}: ${widget.maxPercent.toStringAsFixed(0)}%'
                  : widget.maxAmount > 0
                  ? '${context.l10n.maxDiscountAmount}: ${widget.currency}${widget.maxAmount.toStringAsFixed(2)}'
                  : null,
            ),
            onChanged: (_) => setState(() {}),
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
            onPressed: () {
              widget.onClear!();
              Navigator.pop(context);
            },
            child: Text(
              l10n.discountClear,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: value > 0
              ? () {
                  final effectiveValue = _type == 'PERCENT'
                      ? value.clamp(0.0, widget.maxPercent)
                      : widget.maxAmount > 0
                      ? value.clamp(0.0, widget.maxAmount)
                      : value;
                  widget.onApply(_type, effectiveValue);
                  Navigator.pop(context);
                }
              : null,
          child: Text(l10n.discountApply),
        ),
      ],
    );
  }
}
