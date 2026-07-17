import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({
    super.key,
    required this.onManageCategories,
    required this.onAdd,
    this.onImport,
  });

  final VoidCallback onManageCategories;
  final VoidCallback onAdd;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: bottomInset + 12,
          ),
          child: Row(
            children: [
              if (onImport != null) ...[
                IconButton.outlined(
                  onPressed: onImport,
                  tooltip: l10n.importProducts,
                  icon: const Icon(Icons.file_upload_outlined, size: 20),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onManageCategories,
                  icon: const Icon(Icons.folder_outlined, size: 20),
                  label: Text(l10n.manageCategories),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(l10n.addProduct),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
