import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/discount_preset_list_tile.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DiscountPresetsSection extends StatelessWidget {
  const DiscountPresetsSection({
    super.key,
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
            color: st.activeAccentContainer,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: st.activeAccent,
                size: 24,
              ),
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
