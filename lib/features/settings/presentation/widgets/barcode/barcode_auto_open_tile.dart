import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_dropdown_tile.dart';

class BarcodeAutoOpenTile extends StatelessWidget {
  const BarcodeAutoOpenTile({
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
    final delay = settings.barcodeAutoOpenManualDelay;
    final delayOptions = [0, 5, 10, 15, 20, 30];
    String delayLabel(int v) =>
        v == 0 ? l10n.disabled : '$v${l10n.secondsSuffix}';

    return SettingsDropdownTile<int>(
      icon: Icons.timer_outlined,
      title: l10n.barcodeAutoOpenManual,
      accentColor: st.softAccent,
      value: delay,
      items: delayOptions,
      itemLabelBuilder: delayLabel,
      onChanged: (v) {
        cubit.updateField((s) => s.copyWith(barcodeAutoOpenManualDelay: v));
      },
    );
  }
}
