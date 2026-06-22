import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/discount_preset_edit_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount_policy_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount_policy_summary_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount_preset_list_tile.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

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
              _DiscountPresetsSection(
                presets: s.discountPresets,
                activePresetId: s.activeDiscountPresetId,
                activePresetName: activePreset.name,
                st: st,
                l10n: l10n,
                onAdd: () => _addPreset(context, cubit, st, l10n),
                onDelete: (index) =>
                    _deletePreset(context, cubit, index, st, l10n),
                onEdit: (index, preset, isActive, canDelete) =>
                    _pushEditPage(context, index, preset, isActive, canDelete),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addPreset(
    BuildContext context,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
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

  void _deletePreset(
    BuildContext context,
    SettingsCubit cubit,
    int index,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
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
}

class _DiscountPresetsSection extends StatelessWidget {
  const _DiscountPresetsSection({
    required this.presets,
    required this.activePresetId,
    required this.activePresetName,
    required this.st,
    required this.l10n,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
  });

  final List<DiscountPreset> presets;
  final String activePresetId;
  final String activePresetName;
  final SettingsThemeExtension st;
  final AppLocalizations l10n;
  final VoidCallback onAdd;
  final void Function(int index) onDelete;
  final void Function(
    int index,
    DiscountPreset preset,
    bool isActive,
    bool canDelete,
  )
  onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10),
          child: Text(
            l10n.discountPresetsTitle.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: st.mutedText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: st.softAccentContainer,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.local_offer_outlined, color: st.softAccent, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${presets.length} ${l10n.discountPresetsTitle.toLowerCase()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: st.softTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.activeDiscountPreset}: $activePresetName',
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
        const SizedBox(height: 12),
        ...presets.asMap().entries.map((entry) {
          final index = entry.key;
          final preset = entry.value;
          final isActive = preset.id == activePresetId;
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: DiscountPresetListTile(
              preset: preset,
              isActive: isActive,
              canDelete: presets.length > 1,
              onTap: () => onEdit(index, preset, isActive, presets.length > 1),
              onDelete: () => onDelete(index),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.addDiscountPreset),
          ),
        ),
      ],
    );
  }
}
