import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount_policy_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount_policy_summary_card.dart';

class DiscountPolicySettingsPage extends StatelessWidget {
  const DiscountPolicySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();

        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settingsDiscountPolicy)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              DiscountPolicySummaryCard(
                enableItemDiscount: s.enableItemDiscount,
                enableCartDiscount: s.enableCartDiscount,
                defaultDiscountType: s.defaultDiscountType,
                maxDiscountPercent: s.maxDiscountPercent,
                maxDiscountAmount: s.maxDiscountAmount,
                currency: s.currency,
              ),
              const SizedBox(height: 24),
              DiscountPolicySettingsForm(
                settings: s,
                onUpdate: (next) => cubit.updateField((_) => next),
              ),
            ],
          ),
        );
      },
    );
  }
}
