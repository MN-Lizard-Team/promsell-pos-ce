import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_shared_widgets.dart';

class SalesDisplaySection extends StatelessWidget {
  const SalesDisplaySection({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SalesSharedWidgets.buildSectionTitle(context, 'Display'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            children: [
              SalesSharedWidgets.buildSwitchTile(
                context: context,
                icon: Icons.view_compact_outlined,
                title: l10n.settingsCompactCartMode,
                subtitle: l10n.settingsCompactModeSubtitle,
                value: settings.cartCompactMode,
                onChanged: (v) =>
                    onUpdate(settings.copyWith(cartCompactMode: v)),
              ),
              Divider(
                height: 1,
                indent: st.dividerIndent,
                endIndent: st.dividerIndent,
                color: st.cardBorderColor.withValues(alpha: 0.5),
              ),
              SalesSharedWidgets.buildSwitchTile(
                context: context,
                icon: Icons.density_small,
                title: l10n.settingsUltraCompactMode,
                subtitle: l10n.settingsUltraModeSubtitle,
                value: settings.ultraCompactMode,
                onChanged: (v) =>
                    onUpdate(settings.copyWith(ultraCompactMode: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
