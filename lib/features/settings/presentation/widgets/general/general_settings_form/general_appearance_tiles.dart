import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class GeneralAppearanceTiles extends StatelessWidget {
  const GeneralAppearanceTiles({
    super.key,
    required this.settings,
    required this.onUpdate,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final s = settings;

    // accessibilityMode UI hidden until real text-scale / contrast is wired.
    return Column(children: [_buildThemeTile(context, s, st, l10n)]);
  }

  Widget _buildThemeTile(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final label = switch (s.themeModeName) {
      'light' => l10n.settingsThemeLight,
      'dark' => l10n.settingsThemeDark,
      _ => l10n.settingsThemeSystem,
    };

    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(TablerIcons.palette, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.settingsTheme,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: st.softAccent,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 20),
        ],
      ),
      onTap: () => _showThemeDialog(context, s, st, l10n),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final isSelected = mode.name == s.themeModeName;
            final label = switch (mode) {
              ThemeMode.light => l10n.settingsThemeLight,
              ThemeMode.dark => l10n.settingsThemeDark,
              ThemeMode.system => l10n.settingsThemeSystem,
            };
            final icon = switch (mode) {
              ThemeMode.light => TablerIcons.sun,
              ThemeMode.dark => TablerIcons.moon,
              ThemeMode.system => TablerIcons.brightnessAuto,
            };
            return ListTile(
              leading: Icon(icon, color: isSelected ? st.softAccent : null),
              title: Text(label),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: st.softAccent)
                  : null,
              onTap: () {
                HapticFeedback.lightImpact();
                onUpdate(s.copyWith(themeModeName: mode.name));
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
