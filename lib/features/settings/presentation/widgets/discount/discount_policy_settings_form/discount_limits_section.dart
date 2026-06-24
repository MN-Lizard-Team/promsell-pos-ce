import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_shared_widgets.dart';

class DiscountLimitsSection extends StatelessWidget {
  const DiscountLimitsSection({
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
        DiscountSharedWidgets.buildSectionTitle(context, 'Limits'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            children: [
              DiscountSharedWidgets.buildLimitTile(
                context: context,
                icon: Icons.percent_outlined,
                label: l10n.maxDiscountPercent,
                displayValue: '${s.maxDiscountPercent.toStringAsFixed(0)}%',
                value: s.maxDiscountPercent,
                min: 0,
                max: 100,
                presets: const [0.0, 25.0, 50.0, 75.0, 100.0],
                onChanged: (v) => onUpdate(s.copyWith(maxDiscountPercent: v)),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              DiscountSharedWidgets.buildLimitTile(
                context: context,
                icon: Icons.trending_down_outlined,
                label: l10n.maxDiscountAmount,
                displayValue: s.maxDiscountAmount <= 0
                    ? l10n.maxAmountNoLimit
                    : '${s.currency}${s.maxDiscountAmount.toStringAsFixed(0)}',
                value: s.maxDiscountAmount,
                min: 0,
                max: 999999,
                presets: const [0.0, 100.0, 500.0, 1000.0],
                onChanged: (v) => onUpdate(s.copyWith(maxDiscountAmount: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
