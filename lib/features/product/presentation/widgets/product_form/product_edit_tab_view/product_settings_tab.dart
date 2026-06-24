import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/danger_zone_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';

class ProductSettingsTab extends StatelessWidget {
  const ProductSettingsTab({
    super.key,
    required this.isActive,
    required this.isEditing,
    required this.onActiveChanged,
    required this.onDelete,
    required this.productName,
  });

  final bool isActive;
  final bool isEditing;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onDelete;
  final String productName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isEditing)
            FormSectionCard(
              icon: Icons.settings_outlined,
              title: context.l10n.settingsTitle,
              child: ModernToggleCard(
                icon: Icons.visibility,
                title: context.l10n.showProduct,
                value: isActive,
                onChanged: onActiveChanged,
                activeColor: theme.colorScheme.primary,
              ),
            ),
          if (isEditing) ...[
            const SizedBox(height: 16),
            DangerZoneCard(
              icon: Icons.delete_outline,
              title: context.l10n.deleteProduct,
              subtitle: context.l10n.confirmDeleteProduct(productName),
              actionLabel: context.l10n.delete,
              onAction: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}
