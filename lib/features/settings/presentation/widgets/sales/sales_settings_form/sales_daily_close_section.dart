import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_shared_widgets.dart';

class SalesDailyCloseSection extends StatelessWidget {
  const SalesDailyCloseSection({
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
        SalesSharedWidgets.buildSectionTitle(context, 'Daily Close'),
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
                icon: Icons.lock_clock_outlined,
                title: l10n.settingsDailyCloseLockTitle,
                subtitle: l10n.settingsDailyCloseLockSubtitle,
                value: settings.dailyCloseLock,
                onChanged: (v) =>
                    onUpdate(settings.copyWith(dailyCloseLock: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
