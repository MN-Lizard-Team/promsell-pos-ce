import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_overlay_icon_picker.dart';

class PromptpaySettingsTiles extends StatelessWidget {
  const PromptpaySettingsTiles({
    super.key,
    required this.settings,
    required this.cubit,
    required this.st,
  });

  final Settings settings;
  final SettingsCubit cubit;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        ListTile(
          minTileHeight: st.tileMinHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(l10n.promptpayTimeoutSetting),
          subtitle: Text('${settings.promptPayTimeout ~/ 60} ${l10n.minutes}'),
          trailing: SizedBox(
            width: 160,
            child: Slider(
              value: settings.promptPayTimeout.toDouble(),
              min: 60,
              max: 300,
              divisions: 4,
              label: '${settings.promptPayTimeout ~/ 60} min',
              onChanged: (v) {
                HapticFeedback.selectionClick();
                cubit.updateField(
                  (current) => current.copyWith(promptPayTimeout: v.round()),
                );
              },
            ),
          ),
        ),
        ListTile(
          minTileHeight: st.tileMinHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(l10n.promptpaySoundEnabled),
          trailing: Switch(
            value: settings.promptPaySoundEnabled,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              cubit.updateField(
                (current) => current.copyWith(promptPaySoundEnabled: v),
              );
            },
          ),
        ),
        ListTile(
          minTileHeight: st.tileMinHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(l10n.settingsDefaultQrType),
          trailing: SizedBox(
            width: 200,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'transfer',
                  label: Text(l10n.settingsDefaultQrTypeTransfer),
                ),
                ButtonSegment(
                  value: 'bill',
                  label: Text(l10n.settingsDefaultQrTypeBill),
                ),
              ],
              selected: {settings.defaultQrType},
              onSelectionChanged: (v) {
                HapticFeedback.selectionClick();
                cubit.updateField(
                  (current) => current.copyWith(defaultQrType: v.first),
                );
              },
            ),
          ),
        ),
        ListTile(
          minTileHeight: st.tileMinHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(l10n.settingsAutoConfirmAfterSlip),
          subtitle: Text(
            l10n.settingsAutoConfirmAfterSlipHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: st.mutedText),
          ),
          trailing: Switch(
            value: settings.autoConfirmAfterSlip,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              cubit.updateField(
                (current) => current.copyWith(autoConfirmAfterSlip: v),
              );
            },
          ),
        ),
        ListTile(
          minTileHeight: st.tileMinHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(l10n.settingsQrOverlayIcon),
          subtitle: PromptpayOverlayIconPicker(
            settings: settings,
            cubit: cubit,
          ),
        ),
      ],
    );
  }
}
