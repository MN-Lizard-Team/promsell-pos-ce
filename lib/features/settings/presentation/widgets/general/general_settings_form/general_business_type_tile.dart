import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class GeneralBusinessTypeTile extends StatelessWidget {
  const GeneralBusinessTypeTile({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final isRestaurant = settings.isRestaurantMode;

    return MergeSemantics(
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          minTileHeight: st.tileMinHeight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: st.iconSize,
            height: st.iconSize,
            decoration: BoxDecoration(
              color: st.iconContainerBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRestaurant ? Icons.restaurant_outlined : Icons.store_outlined,
              color: st.softAccent,
              size: 24,
            ),
          ),
          title: Text(
            l10n.businessType,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            isRestaurant
                ? l10n.businessTypeRestaurant
                : l10n.businessTypeRetail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: st.softTextSecondary,
              fontSize: 14,
            ),
          ),
          trailing: SegmentedButton<BusinessType>(
            segments: [
              ButtonSegment(
                value: BusinessType.retail,
                icon: const Icon(Icons.store_outlined, size: 18),
                label: Text(
                  l10n.businessTypeRetail,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              ButtonSegment(
                value: BusinessType.restaurant,
                icon: const Icon(Icons.restaurant_outlined, size: 18),
                label: Text(
                  l10n.businessTypeRestaurant,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            selected: {settings.businessType},
            onSelectionChanged: (selection) {
              HapticFeedback.lightImpact();
              onUpdate(settings.copyWith(businessType: selection.first));
            },
            style: const ButtonStyle(
              visualDensity: VisualDensity(horizontal: -3, vertical: -2),
            ),
          ),
        ),
      ),
    );
  }
}
