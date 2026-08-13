import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_summary_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.settings != curr.settings,
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();

        return SettingsLeafChrome(
          title: context.l10n.settingsGeneral,
          header: GeneralSummaryCard(locale: s.locale, themeMode: s.themeMode),
          children: [
            GeneralSettingsForm(
              settings: s,
              onUpdate: (next) => cubit.updateField((_) => next),
            ),
          ],
        );
      },
    );
  }
}
