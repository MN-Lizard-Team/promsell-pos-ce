import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class GeneralSettingsForm extends StatelessWidget {
  const GeneralSettingsForm({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final s = settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionCard(
          title: l10n.generalSettingsLanguageRegion,
          children: [_buildLanguageTile(context, s, st, l10n)],
        ),
        const SizedBox(height: 24),
        SettingsSectionCard(
          title: l10n.generalSettingsAppearance,
          children: [
            _buildThemeTile(context, s, st, l10n),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: st.cardBorderColor,
            ),
            _buildCompactCartTile(context, s, st, l10n),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: st.cardBorderColor,
            ),
            _buildAccessibilityTile(context, s, st, l10n),
          ],
        ),
        const SizedBox(height: 24),
        _GeneralInfoCard(st: st, l10n: l10n),
        const SizedBox(height: 24),
        _buildResetTile(context, s, st, l10n),
      ],
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final label = s.locale.languageCode == 'th'
        ? l10n.langThai
        : l10n.langEnglish;

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
        child: Icon(Icons.language_outlined, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.settingsLanguage,
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
      onTap: () => _showLanguageDialog(context, s, st, l10n),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final options = const [Locale('th'), Locale('en')];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((locale) {
            final isSelected = locale == s.locale;
            final label = locale.languageCode == 'th'
                ? l10n.langThai
                : l10n.langEnglish;
            return _DialogOptionTile(
              icon: Icons.language,
              label: label,
              isSelected: isSelected,
              st: st,
              onTap: () {
                HapticFeedback.lightImpact();
                onUpdate(s.copyWith(locale: locale));
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
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

  Widget _buildThemeTile(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final label = switch (s.themeMode) {
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
      ThemeMode.system => l10n.settingsThemeSystem,
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
        child: Icon(Icons.dark_mode_outlined, color: st.softAccent, size: 24),
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
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    IconData themeIcon(ThemeMode mode) {
      return switch (mode) {
        ThemeMode.light => Icons.wb_sunny,
        ThemeMode.dark => Icons.nights_stay,
        ThemeMode.system => Icons.brightness_auto,
      };
    }

    Color themeColor(ThemeMode mode) {
      return switch (mode) {
        ThemeMode.light => Colors.amber,
        ThemeMode.dark => Colors.indigo,
        ThemeMode.system => Colors.teal,
      };
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final isSelected = mode == s.themeMode;
            final label = switch (mode) {
              ThemeMode.light => l10n.settingsThemeLight,
              ThemeMode.dark => l10n.settingsThemeDark,
              ThemeMode.system => l10n.settingsThemeSystem,
            };
            return _DialogOptionTile(
              icon: themeIcon(mode),
              label: label,
              isSelected: isSelected,
              accentColor: themeColor(mode),
              st: st,
              onTap: () {
                HapticFeedback.lightImpact();
                onUpdate(s.copyWith(themeMode: mode));
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

  Widget _buildAccessibilityTile(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
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
          child: Icon(
            Icons.accessibility_new_outlined,
            color: st.softAccent,
            size: 24,
          ),
        ),
        title: Text(
          l10n.settingsAccessibilityMode,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          l10n.settingsAccessibilityModeHint,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: st.mutedText),
        ),
        trailing: Switch(
          value: s.accessibilityMode,
          onChanged: (v) {
            HapticFeedback.lightImpact();
            onUpdate(s.copyWith(accessibilityMode: v));
          },
          activeThumbColor: st.softAccent,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onUpdate(s.copyWith(accessibilityMode: !s.accessibilityMode));
        },
      ),
    );
  }

  Widget _buildCompactCartTile(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
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
          child: Icon(
            Icons.shopping_bag_outlined,
            color: st.softAccent,
            size: 24,
          ),
        ),
        title: Text(
          l10n.settingsCompactCartMode,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          l10n.settingsCompactModeSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: st.mutedText),
        ),
        trailing: Switch(
          value: s.cartCompactMode,
          onChanged: (v) {
            HapticFeedback.lightImpact();
            final next = s.copyWith(cartCompactMode: v);
            onUpdate(
              next.cartCompactMode
                  ? next.copyWith(ultraCompactMode: false)
                  : next,
            );
          },
          activeThumbColor: st.softAccent,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          final next = s.copyWith(cartCompactMode: !s.cartCompactMode);
          onUpdate(
            next.cartCompactMode
                ? next.copyWith(ultraCompactMode: false)
                : next,
          );
        },
      ),
    );
  }

  Widget _buildResetTile(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
      ),
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
          child: Icon(Icons.restore, color: st.mutedText, size: 24),
        ),
        title: Text(
          l10n.generalSettingsReset,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          l10n.generalSettingsResetConfirm,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: st.mutedText),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: st.softTextSecondary,
          size: 20,
        ),
        onTap: () => _showResetConfirmDialog(context, s, st, l10n),
      ),
    );
  }

  void _showResetConfirmDialog(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.generalSettingsResetTitle),
        content: Text(l10n.generalSettingsResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onUpdate(
                s.copyWith(
                  locale: const Locale('th'),
                  themeMode: ThemeMode.system,
                  accessibilityMode: false,
                ),
              );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsSaved),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _DialogOptionTile extends StatelessWidget {
  const _DialogOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.st,
    required this.onTap,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final SettingsThemeExtension st;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? st.softAccent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : st.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : st.cardBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : st.softTextSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : st.softTextSecondary,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _GeneralInfoCard extends StatelessWidget {
  const _GeneralInfoCard({required this.st, required this.l10n});

  final SettingsThemeExtension st;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: st.iconContainerBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: st.softAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.generalSettingsInfoDescription,
              style: TextStyle(
                fontSize: 13,
                color: st.softTextSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
