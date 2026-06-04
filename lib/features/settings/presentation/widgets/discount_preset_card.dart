import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';

class DiscountPresetCard extends StatelessWidget {
  const DiscountPresetCard({
    super.key,
    required this.preset,
    required this.isActive,
    required this.onChanged,
    required this.onDelete,
    required this.onSetActive,
    this.canDelete = true,
  });

  final DiscountPreset preset;
  final bool isActive;
  final ValueChanged<DiscountPreset> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onSetActive;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: preset.name,
                    decoration: InputDecoration(
                      labelText: l10n.discountPresetName,
                      isDense: true,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: theme.textTheme.titleSmall,
                    onChanged: (v) => onChanged(preset.copyWith(name: v)),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'PERCENT', label: Text('%')),
                    ButtonSegment(value: 'AMOUNT', label: Text('฿')),
                  ],
                  selected: {preset.type},
                  onSelectionChanged: (v) =>
                      onChanged(preset.copyWith(type: v.first)),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...preset.values.map((v) {
                  final label = preset.type == 'PERCENT'
                      ? '${v.toStringAsFixed(0)}%'
                      : '฿${v.toStringAsFixed(2)}';
                  return Chip(
                    label: Text(label),
                    onDeleted: () {
                      final newValues = preset.values
                          .where((e) => e != v)
                          .toList();
                      onChanged(preset.copyWith(values: newValues));
                    },
                    visualDensity: VisualDensity.compact,
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addPresetValue),
                  onPressed: () => _showAddValueDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isActive)
                  TextButton.icon(
                    onPressed: onSetActive,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(l10n.activeDiscountPreset),
                  ),
                if (canDelete)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    tooltip: l10n.deleteDiscountPreset,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddValueDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.addPresetValue),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: preset.type == 'PERCENT' ? '%' : '฿',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val > 0) {
                onChanged(preset.copyWith(values: [...preset.values, val]));
              }
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.discountApply),
          ),
        ],
      ),
    );
  }
}
