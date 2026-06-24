import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_shared_widgets.dart';

class DiscountDefaultSection extends StatelessWidget {
  const DiscountDefaultSection({
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
    final s = settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DiscountSharedWidgets.buildSectionTitle(context, 'Default'),
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
              DiscountSharedWidgets.buildChoiceRow(
                context: context,
                icon: Icons.settings_outlined,
                label: l10n.defaultDiscountType,
                options: const ['PERCENT', 'AMOUNT'],
                selected: s.defaultDiscountType,
                onSelected: (v) => onUpdate(s.copyWith(defaultDiscountType: v)),
                labelBuilder: (v) {
                  if (v == 'PERCENT') return l10n.discountTypePercent;
                  return l10n.discountTypeAmount;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
