import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_summary_card.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();

        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settingsGeneral)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              GeneralSummaryCard(
                locale: s.locale,
                themeMode: s.themeMode,
                accessibilityMode: s.accessibilityMode,
              ),
              const SizedBox(height: 24),
              GeneralSettingsForm(
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
