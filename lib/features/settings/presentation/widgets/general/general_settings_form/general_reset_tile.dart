import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class GeneralResetTile extends StatelessWidget {
  const GeneralResetTile({
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          minTileHeight: st.tileMinHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
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
      ),
    );
  }

  void _showResetConfirmDialog(
    BuildContext context,
    Settings s,
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
