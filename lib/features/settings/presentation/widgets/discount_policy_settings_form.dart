import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class DiscountPolicySettingsForm extends StatelessWidget {
  const DiscountPolicySettingsForm({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final s = settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Toggles'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSwitchTile(
                context: context,
                icon: Icons.local_offer_outlined,
                title: l10n.enableItemDiscount,
                value: s.enableItemDiscount,
                onChanged: (v) => onUpdate(s.copyWith(enableItemDiscount: v)),
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.local_offer,
                title: l10n.enableCartDiscount,
                value: s.enableCartDiscount,
                onChanged: (v) => onUpdate(s.copyWith(enableCartDiscount: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Default'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChoiceRow(
                context: context,
                icon: Icons.settings_outlined,
                label: l10n.defaultDiscountType,
                options: const ['PERCENT', 'AMOUNT'],
                selected: s.defaultDiscountType,
                onSelected: (v) => onUpdate(s.copyWith(defaultDiscountType: v)),
                labelBuilder: (v) {
                  if (v == 'PERCENT') return l10n.discountTypePercent;
                  return l10n.discountTypeAmount;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Limits'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            children: [
              _buildLimitTile(
                context: context,
                icon: Icons.percent_outlined,
                label: l10n.maxDiscountPercent,
                displayValue: '${s.maxDiscountPercent.toStringAsFixed(0)}%',
                value: s.maxDiscountPercent,
                min: 0,
                max: 100,
                presets: const [0.0, 25.0, 50.0, 75.0, 100.0],
                onChanged: (v) => onUpdate(s.copyWith(maxDiscountPercent: v)),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildLimitTile(
                context: context,
                icon: Icons.trending_down_outlined,
                label: l10n.maxDiscountAmount,
                displayValue: s.maxDiscountAmount <= 0
                    ? l10n.maxAmountNoLimit
                    : '${s.currency}${s.maxDiscountAmount.toStringAsFixed(0)}',
                value: s.maxDiscountAmount,
                min: 0,
                max: 999999,
                presets: const [0.0, 100.0, 500.0, 1000.0],
                onChanged: (v) => onUpdate(s.copyWith(maxDiscountAmount: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimitTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String displayValue,
    required double value,
    required double min,
    required double max,
    required List<double> presets,
    required ValueChanged<double> onChanged,
  }) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: st.softAccent, size: 22),
      title: Text(
        label,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: st.softTextPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 20),
        ],
      ),
      onTap: () => _showLimitDialog(
        context: context,
        label: label,
        value: value,
        min: min,
        max: max,
        presets: presets,
        onChanged: onChanged,
      ),
    );
  }

  void _showLimitDialog({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required List<double> presets,
    required ValueChanged<double> onChanged,
  }) {
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: value.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((preset) {
                return ChoiceChip(
                  label: Text(preset.toStringAsFixed(0)),
                  selected: false,
                  onSelected: (_) {
                    ctrl.text = preset.toStringAsFixed(0);
                  },
                  selectedColor: st.softAccentContainer,
                  backgroundColor: st.cardBackground,
                  side: BorderSide(color: st.cardBorderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final n = double.tryParse(ctrl.text.trim());
              if (n != null) {
                onChanged(n.clamp(min, max));
              }
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10, top: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: st.mutedText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildChoiceRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
    required String Function(String) labelBuilder,
  }) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: st.softAccent, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return ChoiceChip(
              label: Text(
                labelBuilder(opt),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? st.softTextPrimary : st.softTextSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(opt),
              selectedColor: st.softAccentContainer,
              backgroundColor: st.cardBackground,
              side: BorderSide(
                color: isSelected ? st.softAccent : st.cardBorderColor,
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return MergeSemantics(
      child: ListTile(
        minTileHeight: st.tileMinHeight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: st.iconSize,
          height: st.iconSize,
          decoration: BoxDecoration(
            color: st.iconContainerBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: st.softAccent, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: (v) {
            HapticFeedback.lightImpact();
            onChanged(v);
          },
          activeThumbColor: st.softAccent,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(!value);
        },
      ),
    );
  }
}
