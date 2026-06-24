import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_shared_widgets.dart';

class SalesPreferencesSection extends StatelessWidget {
  const SalesPreferencesSection({
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
        SalesSharedWidgets.buildSectionTitle(context, 'Preferences'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SalesSharedWidgets.buildChoiceRow(
                context: context,
                icon: Icons.attach_money_outlined,
                label: l10n.settingsCurrency,
                options: const ['฿', '\$', '€', '¥'],
                selected: settings.currency,
                onSelected: (v) => onUpdate(settings.copyWith(currency: v)),
              ),
              const SizedBox(height: 20),
              SalesSharedWidgets.buildChoiceRow(
                context: context,
                icon: Icons.calendar_today_outlined,
                label: l10n.settingsDateFormat,
                options: const ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'],
                selected: settings.dateFormat,
                onSelected: (v) => onUpdate(settings.copyWith(dateFormat: v)),
                labelBuilder: (v) {
                  if (v == 'dd/MM/yyyy') return '31/12/2025';
                  if (v == 'MM/dd/yyyy') return '12/31/2025';
                  return '2025-12-31';
                },
              ),
              const SizedBox(height: 20),
              SalesSharedWidgets.buildDraftsTile(
                context: context,
                icon: Icons.folder_copy_outlined,
                label: l10n.settingsMaxDrafts,
                value: settings.maxDrafts,
                min: 5,
                max: 100,
                onChanged: (v) => onUpdate(settings.copyWith(maxDrafts: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
