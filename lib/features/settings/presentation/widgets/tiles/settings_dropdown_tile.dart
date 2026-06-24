import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SettingsDropdownTile<T> extends StatelessWidget {
  const SettingsDropdownTile({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
    this.accentColor,
    this.itemLabelBuilder,
    super.key,
  });

  final String title;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final IconData? icon;
  final Color? accentColor;
  final String Function(T)? itemLabelBuilder;

  Future<void> _showBottomSheet(BuildContext context) async {
    HapticFeedback.selectionClick();
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final accent = accentColor ?? st.softAccent;
    final label = itemLabelBuilder ?? (v) => v.toString();

    final result = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: st.cardBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map((item) {
                  final isSelected = item == value;
                  return ListTile(
                    leading: isSelected
                        ? Icon(Icons.check, color: accent, size: 20)
                        : const SizedBox(width: 20),
                    title: Text(
                      label(item),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? accent
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () => Navigator.of(ctx).pop(item),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result != value) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final accent = accentColor ?? st.softAccent;
    final displayValue = itemLabelBuilder?.call(value) ?? value.toString();

    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: icon != null
          ? Container(
              width: st.iconSize,
              height: st.iconSize,
              decoration: BoxDecoration(
                color: st.iconContainerBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 24),
            )
          : null,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        displayValue,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: st.softAccent,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: () => _showBottomSheet(context),
    );
  }
}
