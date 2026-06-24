import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

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
    final theme = Theme.of(context);
    final delay = settings.barcodeAutoOpenManualDelay;
    final delayOptions = [0, 5, 10, 15, 20, 30];
    String delayLabel(int v) =>
        v == 0 ? l10n.disabled : '$v${l10n.secondsSuffix}';

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.timer_outlined, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.barcodeAutoOpenManual,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        delay == 0 ? l10n.disabled : '$delay${l10n.secondsSuffix}',
        style: TextStyle(fontSize: 13, color: st.softTextSecondary),
      ),
      trailing: DropdownButton<int>(
        value: delay,
        underline: const SizedBox(),
        items: delayOptions
            .map((v) => DropdownMenuItem(value: v, child: Text(delayLabel(v))))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            cubit.updateField((s) => s.copyWith(barcodeAutoOpenManualDelay: v));
          }
        },
      ),
    );
  }
}
