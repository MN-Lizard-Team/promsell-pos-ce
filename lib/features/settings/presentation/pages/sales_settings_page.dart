import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_state_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class SalesSettingsPage extends StatefulWidget {
  const SalesSettingsPage({super.key});

  @override
  State<SalesSettingsPage> createState() => _SalesSettingsPageState();
}

class _SalesSettingsPageState extends State<SalesSettingsPage>
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
            title: context.l10n.settingsSales,
            heroIcon: TablerIcons.deviceMobile,
            heroAccent: AppColors.primary,
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
          ),
        );
      },
    );
  }
}
