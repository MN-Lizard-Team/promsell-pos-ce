import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/secure_screen.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_biller_id_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_id_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_info_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_settings_tiles.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_state_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class PromptpaySettingsPage extends StatefulWidget {
  const PromptpaySettingsPage({super.key});

  @override
  State<PromptpaySettingsPage> createState() => _PromptpaySettingsPageState();
}

class _PromptpaySettingsPageState extends State<PromptpaySettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // V092-B.5: hide PromptPay ID entry from screenshots / Recents preview.
    SecureScreen.setSecure(true);
  }

  @override
  void dispose() {
    SecureScreen.setSecure(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.settings != curr.settings || prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final st = context.settingsTheme;

        return SettingsStateView(
          state: state,
          onRetry: cubit.load,
          builder: (s) => SettingsLeafChrome(
            title: l10n.promptpay,
            heroIcon: TablerIcons.qrcode,
            heroAccent: AppColors.accent,
            header: PromptpayPreviewCard(
              promptpayId: s.promptpayId,
              st: st,
              l10n: l10n,
              overlayIcon: s.qrOverlayIcon,
            ),
            children: [
              SettingsSectionCard(
                title: l10n.promptpayAccount,
                accent: AppColors.accent,
                children: [
                  PromptpayIdTile(
                    settings: s,
                    cubit: cubit,
                    st: st,
                    l10n: l10n,
                  ),
                  PromptpayBillerIdTile(
                    settings: s,
                    cubit: cubit,
                    st: st,
                    l10n: l10n,
                  ),
                ],
              ),
              SettingsSectionCard(
                title: l10n.settingsTitle,
                accent: AppColors.accent,
                children: [
                  PromptpaySettingsTiles(settings: s, cubit: cubit, st: st),
                ],
              ),
              PromptpayInfoCard(st: st, l10n: l10n),
            ],
          ),
        );
      },
    );
  }
}
