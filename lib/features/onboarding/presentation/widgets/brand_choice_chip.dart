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
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      selectedColor: primary,
      checkmarkColor: AppColors.textOnPrimary,
      labelStyle: TextStyle(
        color: selected ? AppColors.textOnPrimary : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
