import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// "Recovery Kit" section on the backup settings page: export the SQLCipher
/// key as a password-wrapped `.promkey` file, or import a kit to restore
/// access after key loss (device change, Keystore invalidation).
class RecoveryKitSectionCard extends StatelessWidget {
  const RecoveryKitSectionCard({
    super.key,
    required this.onExport,
    required this.onImport,
  });

  final VoidCallback onExport;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;

    return SettingsSectionCard(
      title: l10n.recoveryKitSectionTitle,
      children: [
        ListTile(
          key: const Key('recovery_kit_export_tile'),
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
            child: Icon(TablerIcons.key, color: st.softAccent, size: 24),
          ),
          title: Text(
            l10n.recoveryKitExportAction,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            l10n.recoveryKitSectionDesc,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: st.mutedText, fontSize: 14),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: st.softTextSecondary,
            size: 24,
          ),
          onTap: onExport,
        ),
        ListTile(
          key: const Key('recovery_kit_import_tile'),
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
            child: Icon(
              TablerIcons.databaseImport,
              color: st.softAccent,
              size: 24,
            ),
          ),
          title: Text(
            l10n.recoveryKitImportAction,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: st.softTextSecondary,
            size: 24,
          ),
          onTap: onImport,
        ),
      ],
    );
  }
}
