import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';

class ReportTopProductsCard extends StatelessWidget {
  const ReportTopProductsCard({super.key, required this.topProducts});

  final Map<String, int> topProducts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.topProducts, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            if (topProducts.isEmpty)
              AppEmptyState(
                icon: Icons.leaderboard_outlined,
                title: context.l10n.noSalesYet,
              )
            else
              ...topProducts.entries.toList().asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final e = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '$rank',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(e.key)),
                      Text(
                        context.l10n.units(e.value),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
