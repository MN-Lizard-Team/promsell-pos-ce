import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

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
            child: Icon(TablerIcons.history, color: st.mutedText, size: 24),
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

  Future<void> _showResetConfirmDialog(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showAppConfirm(
      context,
      title: l10n.generalSettingsResetTitle,
      message: l10n.generalSettingsResetConfirm,
      confirmLabel: l10n.generalSettingsReset,
      cancelLabel: l10n.cancel,
      destructive: true,
      confirmIcon: TablerIcons.refresh,
    );
    if (!confirmed || !context.mounted) return;
    HapticFeedback.lightImpact();
    onUpdate(
      s.copyWith(
        locale: const Locale('th'),
        themeMode: ThemeMode.system,
        accessibilityMode: false,
      ),
    );
    AppSnackBar.success(context, l10n.settingsSaved);
  }
}
