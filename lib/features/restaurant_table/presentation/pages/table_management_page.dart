import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});

  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<TableBloc>().add(const TablesLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tableManagement)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TableBloc, TableState>(
        builder: (context, state) {
          if (state.status == TableBlocStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.tables.isEmpty) {
            return Center(
              child: Text(
                l10n.noTablesYet,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }
          final grouped = <String, List<RestaurantTable>>{};
          for (final t in state.tables) {
            final zone = t.zone ?? '';
            grouped.putIfAbsent(zone, () => []).add(t);
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.key.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 16),
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: entry.value
                        .map(
                          (t) => _TableCard(
                            table: t,
                            onEdit: () => _showAddEditDialog(context, table: t),
                            onDelete: () => _confirmDelete(context, t),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {RestaurantTable? table}) {
    final l10n = context.l10n;
    final isEdit = table != null;
    final nameCtrl = TextEditingController(text: table?.name ?? '');
    final zoneCtrl = TextEditingController(text: table?.zone ?? '');
    final seatsCtrl = TextEditingController(
      text: table?.seats?.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? l10n.editTable : l10n.addTable),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.tableName,
                hintText: l10n.tableNameHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: zoneCtrl,
              decoration: InputDecoration(
                labelText: l10n.tableZone,
                hintText: l10n.tableZoneHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: seatsCtrl,
              decoration: InputDecoration(
                labelText: l10n.tableSeats,
                hintText: l10n.tableSeatsHint,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final zone = zoneCtrl.text.trim().isEmpty
                  ? null
                  : zoneCtrl.text.trim();
              final seats = int.tryParse(seatsCtrl.text.trim());
              if (isEdit) {
                context.read<TableBloc>().add(
                  TableUpdated(
                    table.copyWith(name: name, zone: zone, seats: seats),
                  ),
                );
              } else {
                context.read<TableBloc>().add(
                  TableAdded(name: name, zone: zone, seats: seats),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(MaterialLocalizations.of(ctx).saveButtonLabel),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, RestaurantTable table) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTable),
        content: Text('${l10n.confirmDeleteTable}\n\n${table.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<TableBloc>().add(TableDeleted(table.id));
              Navigator.pop(ctx);
            },
            child: Text(l10n.deleteTable),
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  final RestaurantTable table;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor = switch (table.status) {
      TableStatus.available => Colors.green,
      TableStatus.occupied => Colors.red,
      TableStatus.reserved => Colors.orange,
    };
    final statusLabel = switch (table.status) {
      TableStatus.available => l10n.tableStatusAvailable,
      TableStatus.occupied => l10n.tableStatusOccupied,
      TableStatus.reserved => l10n.tableStatusReserved,
    };

    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.table_restaurant_outlined, size: 32, color: statusColor),
          const SizedBox(height: 8),
          Text(
            table.name,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (table.seats != null) ...[
            const SizedBox(height: 4),
            Text(
              '${table.seats} ${l10n.tableSeats}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            statusLabel,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: statusColor),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                tooltip: l10n.editTable,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                tooltip: l10n.deleteTable,
                color: Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
