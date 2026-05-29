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
  });

  final String title;
  final String currency;
  final String initialType;
  final double? initialValue;
  final void Function(String type, double value) onApply;
  final VoidCallback? onClear;

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
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _type == 'PERCENT' ? '%' : widget.currency,
              border: const OutlineInputBorder(),
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
                  widget.onApply(_type, value);
                  Navigator.pop(context);
                }
              : null,
          child: Text(l10n.discountApply),
        ),
      ],
    );
  }
}
