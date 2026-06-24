import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_preset_edit_form.dart';

class DiscountPresetEditPage extends StatelessWidget {
  const DiscountPresetEditPage({
    super.key,
    required this.index,
    required this.preset,
    required this.isActive,
    required this.canDelete,
  });

  final int index;
  final DiscountPreset preset;
  final bool isActive;
  final bool canDelete;

  void _updatePreset(BuildContext context, DiscountPreset updated) {
    final cubit = context.read<SettingsCubit>();
    cubit.updateField((s) {
      final presets = [...s.discountPresets];
      presets[index] = updated;
      return s.copyWith(discountPresets: presets);
    });
  }

  void _deletePreset(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    cubit.updateField((s) {
      if (s.discountPresets.length <= 1) return s;
      final presets = [...s.discountPresets]..removeAt(index);
      final deletedId = s.discountPresets[index].id;
      final newActiveId = s.activeDiscountPresetId == deletedId
          ? presets.first.id
          : s.activeDiscountPresetId;
      return s.copyWith(
        discountPresets: presets,
        activeDiscountPresetId: newActiveId,
      );
    });
    Navigator.of(context).pop();
  }

  void _setActive(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    cubit.updateField((s) => s.copyWith(activeDiscountPresetId: preset.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final currentPreset = index < s.discountPresets.length
            ? s.discountPresets[index]
            : preset;
        final currentlyActive = currentPreset.id == s.activeDiscountPresetId;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.editDiscountPreset),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: st.cardBackground,
                  borderRadius: BorderRadius.circular(st.cardRadius),
                  border: Border.all(color: st.cardBorderColor),
                ),
                child: DiscountPresetEditForm(
                  preset: currentPreset,
                  isActive: currentlyActive,
                  canDelete: s.discountPresets.length > 1,
                  onUpdate: (p) => _updatePreset(context, p),
                  onDelete: () => _deletePreset(context),
                  onSetActive: () => _setActive(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
