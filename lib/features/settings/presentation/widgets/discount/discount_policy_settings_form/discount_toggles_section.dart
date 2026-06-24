import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_shared_widgets.dart';

class DiscountTogglesSection extends StatelessWidget {
  const DiscountTogglesSection({
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
        DiscountSharedWidgets.buildSectionTitle(context, 'Toggles'),
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
              DiscountSharedWidgets.buildSwitchTile(
                context: context,
                icon: Icons.local_offer_outlined,
                title: l10n.enableItemDiscount,
                value: s.enableItemDiscount,
                onChanged: (v) => onUpdate(s.copyWith(enableItemDiscount: v)),
              ),
              DiscountSharedWidgets.buildSwitchTile(
                context: context,
                icon: Icons.local_offer,
                title: l10n.enableCartDiscount,
                value: s.enableCartDiscount,
                onChanged: (v) => onUpdate(s.copyWith(enableCartDiscount: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
