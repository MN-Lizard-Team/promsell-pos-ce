import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DiscountPresetDialogs {
  DiscountPresetDialogs._();

  static void showAddDialog(
    BuildContext context, {
    required SettingsCubit cubit,
    required SettingsThemeExtension st,
    required AppLocalizations l10n,
  }) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addDiscountPreset),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: l10n.discountPresetName,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              Navigator.of(ctx).pop();
              if (name.isNotEmpty) {
                final preset = DiscountPreset(
                  id: 'preset-${IdGenerator.newId()}',
                  name: name,
                  type: 'PERCENT',
                  values: const [5.0, 10.0],
                );
                cubit.updateField(
                  (s) => s.copyWith(
                    discountPresets: [...s.discountPresets, preset],
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.addDiscountPreset),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.addDiscountPreset),
          ),
        ],
      ),
    );
  }

  static void showDeleteDialog(
    BuildContext context, {
    required SettingsCubit cubit,
    required int index,
    required SettingsThemeExtension st,
    required AppLocalizations l10n,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDiscountPreset),
        content: Text(l10n.deleteDiscountPreset),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.deleteDiscountPreset),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              l10n.deleteDiscountPreset,
              style: TextStyle(color: st.danger),
            ),
          ),
        ],
      ),
    );
  }
}
