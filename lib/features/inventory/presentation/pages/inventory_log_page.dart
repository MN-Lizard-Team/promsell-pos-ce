import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';

class InventoryLogPage extends StatelessWidget {
  const InventoryLogPage({super.key, this.productId});
  final String? productId;

  @override
  Widget build(BuildContext context) {
    final db = sl<AppDatabase>();
    final query = db.select(db.inventoryLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (productId != null) {
      query.where((t) => t.productId.equals(productId!));
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.inventoryLog)),
      body: StreamBuilder<List<InventoryLogData>>(
        stream: query.watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.noInventoryLogs,
            );
          }

          final theme = Theme.of(context);
          final fmt = DateFormat('yyyy-MM-dd HH:mm');

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final log = logs[i];
              final isPositive = log.qtyChange >= 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPositive
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.errorContainer,
                  child: Icon(
                    _iconForType(log.type),
                    color: isPositive ? theme.colorScheme.primary : theme.colorScheme.error,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${isPositive ? '+' : ''}${log.qtyChange}  →  ${log.balanceAfter}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labelForType(context, log.type),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (log.reason != null)
                      Text(
                        log.reason!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                trailing: Text(
                  fmt.format(log.createdAt),
                  style: theme.textTheme.labelSmall,
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) => switch (type) {
    'SALE' => Icons.shopping_cart_outlined,
    'VOID_REVERSAL' => Icons.undo,
    'ADJUSTMENT_IN' => Icons.add_circle_outline,
    'ADJUSTMENT_OUT' => Icons.remove_circle_outline,
    _ => Icons.help_outline,
  };

  String _labelForType(BuildContext context, String type) => switch (type) {
    'SALE' => context.l10n.invLogTypeSale,
    'VOID_REVERSAL' => context.l10n.invLogTypeVoidReversal,
    'ADJUSTMENT_IN' => context.l10n.invLogTypeStockIn,
    'ADJUSTMENT_OUT' => context.l10n.invLogTypeStockOut,
    _ => type,
  };
}
