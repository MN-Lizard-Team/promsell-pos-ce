import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/responsive_settings_picker.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile({super.key, required this.current, required this.onChanged});
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ResponsiveSettingsPicker(
      icon: Icons.brightness_6_outlined,
      title: l10n.settingsTheme,
      child: DropdownButton<ThemeMode>(
        value: current,
        isExpanded: true,
        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: [
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text(l10n.settingsThemeLight),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text(l10n.settingsThemeDark),
          ),
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text(l10n.settingsThemeSystem),
          ),
        ],
        onChanged: (m) {
          if (m != null) {
            HapticFeedback.selectionClick();
            onChanged(m);
          }
        },
      ),
    );
  }
}
