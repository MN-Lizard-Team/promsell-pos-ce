import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/discount_preset_edit_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount_preset_list_tile.dart';

class DiscountPresetsPage extends StatelessWidget {
  const DiscountPresetsPage({super.key});

  void _addPreset(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
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
                _createPresetAndEdit(context, name);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.addDiscountPreset),
          ),
        ],
      ),
    );
  }

  void _createPresetAndEdit(BuildContext context, String name) {
    final cubit = context.read<SettingsCubit>();
    cubit.updateField((s) {
      final preset = DiscountPreset(
        id: 'preset-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: 'PERCENT',
        values: const [5.0, 10.0],
      );
      return s.copyWith(discountPresets: [...s.discountPresets, preset]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.addDiscountPreset),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deletePreset(BuildContext context, int index) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
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
              _doDeletePreset(context, index);
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

  void _doDeletePreset(BuildContext context, int index) {
    final cubit = context.read<SettingsCubit>();
    final l10n = context.l10n;
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
  }

  void _pushEditPage(
    BuildContext context,
    int index,
    DiscountPreset preset,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final l10n = context.l10n;
        final st = context.settingsTheme;
        final activePreset = s.discountPresets.firstWhere(
          (p) => p.id == s.activeDiscountPresetId,
          orElse: () => s.discountPresets.first,
        );

        return Scaffold(
          appBar: AppBar(title: Text(l10n.discountPresetsTitle)),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: st.softAccentContainer,
                  borderRadius: BorderRadius.circular(st.cardRadius),
                  border: Border.all(color: st.cardBorderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      color: st.softAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.discountPresets.length} ${l10n.discountPresetsTitle.toLowerCase()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: st.softTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.activeDiscountPreset}: ${activePreset.name}',
                            style: TextStyle(
                              fontSize: 13,
                              color: st.softTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ...s.discountPresets.asMap().entries.map((entry) {
                final index = entry.key;
                final preset = entry.value;
                final isActive = preset.id == s.activeDiscountPresetId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DiscountPresetListTile(
                    preset: preset,
                    isActive: isActive,
                    canDelete: s.discountPresets.length > 1,
                    onTap: () => _pushEditPage(
                      context,
                      index,
                      preset,
                      isActive,
                      s.discountPresets.length > 1,
                    ),
                    onDelete: () => _deletePreset(context, index),
                  ),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _addPreset(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.addDiscountPreset),
              ),
            ],
          ),
        );
      },
    );
  }
}
