import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

class BrandChoiceChip extends StatelessWidget {
  const BrandChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      child: ChoiceChip(
        label: label,
        selected: selected,
        onSelected: onSelected,
        selectedColor: primary,
        backgroundColor: Colors.transparent,
        side: BorderSide(
          color: selected ? primary : primary.withValues(alpha: 0.3),
        ),
        checkmarkColor: AppColors.textOnPrimary,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle: TextStyle(
          color: selected ? AppColors.textOnPrimary : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
