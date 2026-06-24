import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form.dart';

class SalesSettingsPage extends StatelessWidget {
  const SalesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();

        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settingsSales)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              SalesPreviewCard(
                currency: s.currency,
                dateFormat: s.dateFormat,
                maxDrafts: s.maxDrafts,
                cartCompactMode: s.cartCompactMode,
                ultraCompactMode: s.ultraCompactMode,
              ),
              const SizedBox(height: 24),
              SalesSettingsForm(
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
