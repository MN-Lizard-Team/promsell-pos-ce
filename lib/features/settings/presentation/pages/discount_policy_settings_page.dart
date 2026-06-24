import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/discount_preset_edit_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_summary_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_preset_dialogs.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_presets_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form.dart';

class DiscountPolicySettingsPage extends StatelessWidget {
  const DiscountPolicySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final st = context.settingsTheme;
        final activePreset = s.discountPresets.firstWhere(
          (p) => p.id == s.activeDiscountPresetId,
          orElse: () => s.discountPresets.first,
        );

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsDiscountPolicy)),
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
              const SizedBox(height: 24),
              DiscountPresetsSection(
                presets: s.discountPresets,
                activePresetId: s.activeDiscountPresetId,
                activePresetName: activePreset.name,
                st: st,
                l10n: l10n,
                onAdd: () => DiscountPresetDialogs.showAddDialog(
                  context,
                  cubit: cubit,
                  st: st,
                  l10n: l10n,
                ),
                onDelete: (index) => DiscountPresetDialogs.showDeleteDialog(
                  context,
                  cubit: cubit,
                  index: index,
                  st: st,
                  l10n: l10n,
                ),
                onEdit: (index, preset, isActive, canDelete) =>
                    _pushEditPage(context, index, preset, isActive, canDelete),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pushEditPage(
    BuildContext context,
    int index,
    dynamic preset,
    bool isActive,
    bool canDelete,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) =>
            DiscountPresetEditPage(
              index: index,
              preset: preset,
              isActive: isActive,
              canDelete: canDelete,
            ),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          const begin = Offset(1, 0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
