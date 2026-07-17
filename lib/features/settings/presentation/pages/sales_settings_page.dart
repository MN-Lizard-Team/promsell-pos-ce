import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';

class SalesSettingsPage extends StatelessWidget {
  const SalesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();

        return SettingsLeafChrome(
          title: context.l10n.settingsSales,
          header: SalesPreviewCard(
            currency: s.currency,
            dateFormat: s.dateFormat,
            maxDrafts: s.maxDrafts,
            ultraCompactMode: s.ultraCompactMode,
          ),
          children: [
            SalesSettingsForm(
              settings: s,
              onUpdate: (next) => cubit.updateField((_) => next),
            ),
          ],
        );
      },
    );
  }
}
