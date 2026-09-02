import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_summary_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_state_view.dart';

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
      buildWhen: (prev, curr) =>
          prev.settings != curr.settings || prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();

        return SettingsStateView(
          state: state,
          onRetry: cubit.load,
          builder: (s) => SettingsLeafChrome(
            title: context.l10n.settingsGeneral,
            heroIcon: TablerIcons.settings,
            heroAccent: AppColors.info,
            header: GeneralSummaryCard(
              localeCode: s.localeCode,
              themeModeName: s.themeModeName,
            ),
            children: [
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
