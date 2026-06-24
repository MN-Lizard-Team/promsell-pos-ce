import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class DiscountSharedWidgets {
  DiscountSharedWidgets._();

  static Widget buildSectionTitle(BuildContext context, String title) {
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

  static Widget buildChoiceRow({
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
              selectedColor: st.activeAccentContainer,
              backgroundColor: st.cardBackground,
              side: BorderSide(
                color: isSelected ? st.activeAccent : st.cardBorderColor,
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

  static Widget buildSwitchTile({
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
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(!value);
        },
      ),
    );
  }

  static Widget buildLimitTile({
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
      onTap: () => showLimitDialog(
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

  static void showLimitDialog({
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
                  selectedColor: st.activeAccentContainer,
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
            child: Text(context.l10n.save),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}
