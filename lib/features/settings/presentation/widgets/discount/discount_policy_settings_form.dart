import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_default_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_limits_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_toggles_section.dart';

class DiscountPolicySettingsForm extends StatelessWidget {
  const DiscountPolicySettingsForm({
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
        DiscountTogglesSection(settings: settings, onUpdate: onUpdate),
        const SizedBox(height: 24),
        DiscountDefaultSection(settings: settings, onUpdate: onUpdate),
        const SizedBox(height: 24),
        DiscountLimitsSection(settings: settings, onUpdate: onUpdate),
      ],
    );
  }
}
