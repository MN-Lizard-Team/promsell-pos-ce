import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_info_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_biller_id_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_id_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_settings_tiles.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';

class PromptpaySettingsPage extends StatelessWidget {
  const PromptpaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final st = context.settingsTheme;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.promptpay)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              PromptpayPreviewCard(
                promptpayId: s.promptpayId,
                st: st,
                l10n: l10n,
                overlayIcon: s.qrOverlayIcon,
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.promptpayAccount,
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
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.settingsTitle,
                children: [
                  PromptpaySettingsTiles(settings: s, cubit: cubit, st: st),
                ],
              ),
              const SizedBox(height: 24),
              PromptpayInfoCard(st: st, l10n: l10n),
            ],
          ),
        );
      },
    );
  }
}
