import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class DiscountPresetListTile extends StatelessWidget {
  const DiscountPresetListTile({
    super.key,
    required this.preset,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    this.canDelete = true,
  });

  final DiscountPreset preset;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool canDelete;

  String _typeLabel(BuildContext context) {
    return preset.type == 'PERCENT'
        ? context.l10n.discountTypePercent
        : context.l10n.discountTypeAmount;
  }

  String _valuesLabel() {
    if (preset.values.isEmpty) return '-';
    if (preset.type == 'PERCENT') {
      return preset.values.map((v) => '${v.toStringAsFixed(0)}%').join(', ');
    }
    return preset.values.map((v) => '฿${v.toStringAsFixed(2)}').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? st.softAccentContainer : st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(
          color: isActive ? st.softAccent : st.cardBorderColor,
          width: isActive ? 1.5 : 0.8,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(st.cardRadius),
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              isActive ? Icons.star : Icons.star_border,
              color: isActive ? st.softAccent : st.softTextSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preset.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: st.softTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: st.softAccentContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _typeLabel(context),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: st.softAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _valuesLabel(),
                    style: TextStyle(fontSize: 13, color: st.softTextSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (canDelete)
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: st.danger, size: 20),
                tooltip: context.l10n.deleteDiscountPreset,
              ),
          ],
        ),
      ),
    );
  }
}
