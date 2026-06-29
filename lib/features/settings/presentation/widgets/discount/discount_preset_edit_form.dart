import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class DiscountPresetEditForm extends StatelessWidget {
  const DiscountPresetEditForm({
    super.key,
    required this.preset,
    required this.onUpdate,
    required this.onDelete,
    required this.onSetActive,
    this.canDelete = true,
    this.isActive = false,
  });

  final DiscountPreset preset;
  final ValueChanged<DiscountPreset> onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onSetActive;
  final bool canDelete;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          Icons.label_outline,
          l10n.discountPresetName,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: preset.name,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: st.softTextPrimary,
          ),
          onChanged: (v) => onUpdate(preset.copyWith(name: v)),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: isActive,
          onChanged: isActive ? null : (_) => onSetActive(),
          title: Text(
            l10n.activeDiscountPreset,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: st.softTextPrimary,
            ),
          ),
          activeThumbColor: st.activeAccent,
          activeTrackColor: st.activeAccentContainer,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        const SizedBox(height: 20),
        _buildSectionTitle(
          context,
          Icons.category_outlined,
          l10n.discountPresetType,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTypeChip(context, 'PERCENT', l10n.discountTypePercent),
            const SizedBox(width: 8),
            _buildTypeChip(context, 'AMOUNT', l10n.discountTypeAmount),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionTitle(
          context,
          Icons.format_list_numbered,
          l10n.discountPresetValues,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...preset.values.map((v) => _buildValueChip(context, v)),
            _AddValueChip(
              type: preset.type,
              onAdd: (val) =>
                  onUpdate(preset.copyWith(values: [...preset.values, val])),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (canDelete)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete_outline, size: 18, color: st.danger),
              label: Text(
                l10n.deleteDiscountPreset,
                style: TextStyle(color: st.danger),
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteDiscountPreset),
        content: Text('${preset.name} — ${context.l10n.deleteDiscountPreset}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            child: Text(
              context.l10n.deleteDiscountPreset,
              style: TextStyle(color: context.settingsTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String label) {
    final st = context.settingsTheme;
    return Row(
      children: [
        Icon(icon, color: st.softAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: st.softTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String type, String label) {
    final st = context.settingsTheme;
    final isSelected = preset.type == type;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? st.softTextPrimary : st.softTextSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onUpdate(preset.copyWith(type: type)),
      selectedColor: st.activeAccentContainer,
      backgroundColor: st.cardBackground,
      side: BorderSide(
        color: isSelected ? st.activeAccent : st.cardBorderColor,
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  Widget _buildValueChip(BuildContext context, double v) {
    final st = context.settingsTheme;
    final label = preset.type == 'PERCENT'
        ? '${v.toStringAsFixed(0)}%'
        : '฿${v.toStringAsFixed(2)}';

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: st.softTextPrimary,
        ),
      ),
      onDeleted: () {
        final newValues = preset.values.where((e) => e != v).toList();
        onUpdate(preset.copyWith(values: newValues));
        final removedLabel = preset.type == 'PERCENT'
            ? '${v.toStringAsFixed(0)}%'
            : '฿${v.toStringAsFixed(2)}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.discountPresetRemoved(removedLabel)),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      deleteIconColor: st.danger,
      backgroundColor: st.cardBackground,
      side: BorderSide(color: st.cardBorderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _AddValueChip extends StatelessWidget {
  const _AddValueChip({required this.type, required this.onAdd});

  final String type;
  final ValueChanged<double> onAdd;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    return ActionChip(
      avatar: Icon(Icons.add, size: 18, color: st.softAccent),
      label: Text(
        l10n.addPresetValue,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: st.softAccent,
        ),
      ),
      onPressed: () => _showAddDialog(context),
      backgroundColor: st.cardBackground,
      side: BorderSide(color: st.softAccent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddPresetDialog(type: type, onAdd: onAdd),
    );
  }
}

class _AddPresetDialog extends StatefulWidget {
  const _AddPresetDialog({required this.type, required this.onAdd});

  final String type;
  final ValueChanged<double> onAdd;

  @override
  State<_AddPresetDialog> createState() => _AddPresetDialogState();
}

class _AddPresetDialogState extends State<_AddPresetDialog> {
  late final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    return AlertDialog(
      title: Text(l10n.addPresetValue),
      content: TextField(
        controller: _ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: widget.type == 'PERCENT' ? '%' : '฿',
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final val = double.tryParse(_ctrl.text.trim());
            if (val != null && val > 0) {
              widget.onAdd(val);
              final addedLabel = widget.type == 'PERCENT'
                  ? '${val.toStringAsFixed(0)}%'
                  : '฿${val.toStringAsFixed(2)}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.discountPresetAdded(addedLabel)),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.invalidValue),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(backgroundColor: st.softAccent),
          child: Text(l10n.addPresetValue),
        ),
      ],
    );
  }
}
