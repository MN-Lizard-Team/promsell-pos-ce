import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class GeneralServiceChargeTile extends StatelessWidget {
  const GeneralServiceChargeTile({
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
    final rate = settings.defaultServiceChargeRate;

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
              Icons.add_circle_outline,
              color: st.softAccent,
              size: 24,
            ),
          ),
          title: Text(
            l10n.serviceChargeRate,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            rate > 0 ? '${rate.toStringAsFixed(1)}%' : l10n.businessTypeRetail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: st.softTextSecondary,
              fontSize: 14,
            ),
          ),
          trailing: SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: rate == 0 ? '' : rate.toStringAsFixed(1),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                suffixText: '%',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                final parsed = double.tryParse(value) ?? 0.0;
                HapticFeedback.selectionClick();
                onUpdate(
                  settings.copyWith(
                    defaultServiceChargeRate: parsed.clamp(0.0, 100.0),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
