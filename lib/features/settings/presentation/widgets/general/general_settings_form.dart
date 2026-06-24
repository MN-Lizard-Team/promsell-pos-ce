import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_appearance_tiles.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_info_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_language_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_reset_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';

class GeneralSettingsForm extends StatelessWidget {
  const GeneralSettingsForm({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionCard(
          title: l10n.generalSettingsLanguageRegion,
          children: [
            GeneralLanguageTile(settings: settings, onUpdate: onUpdate),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSectionCard(
          title: l10n.generalSettingsAppearance,
          children: [
            GeneralAppearanceTiles(settings: settings, onUpdate: onUpdate),
          ],
        ),
        const SizedBox(height: 24),
        GeneralInfoCard(st: st, l10n: l10n),
        const SizedBox(height: 24),
        GeneralResetTile(settings: settings, onUpdate: onUpdate),
      ],
    );
  }
}
