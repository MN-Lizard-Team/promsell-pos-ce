import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class ProductFormVisibilityOutcomeStrip extends StatelessWidget {
  const ProductFormVisibilityOutcomeStrip({
    super.key,
    required this.isActive,
    required this.isRecommended,
  });

  final bool isActive;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive
                    ? Icons.check_circle_outline
                    : Icons.visibility_off_outlined,
                size: 16,
                color: isActive ? cs.primary : cs.error,
              ),
              const SizedBox(width: 6),
              Text(
                isActive
                    ? l10n.productSettingsOutcomeVisible
                    : l10n.productSettingsOutcomeHidden,
                style: style?.copyWith(color: isActive ? cs.primary : cs.error),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRecommended ? Icons.star : Icons.star_outline,
                size: 16,
                color: isRecommended ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                isRecommended
                    ? l10n.productSettingsOutcomeRecommended
                    : l10n.productSettingsOutcomeNotRecommended,
                style: style?.copyWith(
                  color: isRecommended ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
