import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_daily_close_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_display_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_preferences_section.dart';

class SalesSettingsForm extends StatelessWidget {
  const SalesSettingsForm({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SalesPreferencesSection(settings: settings, onUpdate: onUpdate),
        const SizedBox(height: 24),
        SalesDisplaySection(settings: settings, onUpdate: onUpdate),
        const SizedBox(height: 24),
        SalesDailyCloseSection(settings: settings, onUpdate: onUpdate),
      ],
    );
  }
}
