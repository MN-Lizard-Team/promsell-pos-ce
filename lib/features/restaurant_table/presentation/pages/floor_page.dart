import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';

class FloorPage extends StatelessWidget {
  const FloorPage({super.key, this.tableBloc, this.draftBloc});

  final TableBloc? tableBloc;
  final DraftBloc? draftBloc;

  @override
  Widget build(BuildContext context) {
    final resolvedTableBloc = tableBloc ?? sl<TableBloc>();
    final resolvedDraftBloc = draftBloc ?? sl<DraftBloc>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: resolvedTableBloc),
        BlocProvider.value(value: resolvedDraftBloc),
      ],
      child: const _FloorView(),
    );
  }
}

class _FloorView extends StatefulWidget {
  const _FloorView();

  @override
  State<_FloorView> createState() => _FloorViewState();
}

class _FloorViewState extends State<_FloorView> {
  String? _pendingTargetName;
  int _lastTransferNonce = 0;

  @override
  void initState() {
    super.initState();
    context.read<TableBloc>().add(const TablesLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TableBloc, TableState>(
      listenWhen: (previous, current) =>
          current.status == TableBlocStatus.failure &&
          previous.status != TableBlocStatus.failure,
      listener: (context, state) {
        AppSnackBar.error(
          context,
          state.errorMessage ?? context.l10n.errorOccurred,
        );
      },
      child: BlocListener<DraftBloc, DraftState>(
        listenWhen: (previous, current) =>
            current.opNonce != previous.opNonce && current.lastOp == 'transfer',
        listener: _handleDraftState,
        child: Scaffold(
          appBar: AppBar(title: Text(context.l10n.floorTitle)),
          body: SafeArea(
            child: BlocBuilder<TableBloc, TableState>(
              builder: (context, state) => _buildContent(context, state),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TableState state) {
    if (state.status == TableBlocStatus.loading && state.tables.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.tables.isEmpty) {
      return Center(child: Text(context.l10n.noTablesYet));
    }

    final grouped = _groupTables(state.tables);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: grouped.entries
          .map((entry) => _buildZone(context, entry.key, entry.value))
          .toList(),
    );
  }

  Map<String, List<RestaurantTable>> _groupTables(
    List<RestaurantTable> tables,
  ) {
    final grouped = <String, List<RestaurantTable>>{};
    for (final table in tables) {
      grouped.putIfAbsent(table.zone?.trim() ?? '', () => []).add(table);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in entries) {
      entry.value.sort(
        (a, b) => a.sortOrder == b.sortOrder
            ? a.name.compareTo(b.name)
            : a.sortOrder.compareTo(b.sortOrder),
      );
    }
    return {for (final entry in entries) entry.key: entry.value};
  }

  Widget _buildZone(
    BuildContext context,
    String zone,
    List<RestaurantTable> tables,
  ) {
    final title = zone.isEmpty ? context.l10n.floorUnzoned : zone;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = _cardWidth(constraints.maxWidth);
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: tables
                    .map(
                      (table) => SizedBox(
                        width: cardWidth,
                        child: _FloorTableCard(
                          table: table,
                          openedAt: _openedAtFor(context, table),
                          onTransfer: table.status == TableStatus.occupied
                              ? () => _showTransferDialog(context, table)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  double _cardWidth(double maxWidth) {
    final columns = maxWidth >= 840
        ? 4
        : maxWidth >= 560
        ? 3
        : maxWidth >= 320
        ? 2
        : 1;
    return (maxWidth - (columns - 1) * 12) / columns;
  }

  DateTime? _openedAtFor(BuildContext context, RestaurantTable table) {
    final draft = context.read<DraftBloc>().state.loadedDraft;
    if (draft?.tableId != table.id) return null;
    return draft?.openedAt;
  }

  void _handleDraftState(BuildContext context, DraftState state) {
    if (state.opNonce == _lastTransferNonce) return;
    _lastTransferNonce = state.opNonce;
    final targetName = _pendingTargetName;
    _pendingTargetName = null;
    if (state.opStatus == DraftOpStatus.success && targetName != null) {
      AppSnackBar.success(
        context,
        context.l10n.tableTransferSuccess(targetName),
      );
      return;
    }
    if (state.opStatus == DraftOpStatus.failure) {
      final message = state.errorMessage == 'tableAlreadyBound'
          ? context.l10n.tableAlreadyBound
          : context.l10n.errorOccurred;
      AppSnackBar.error(context, message);
    }
  }

  Future<void> _showTransferDialog(
    BuildContext context,
    RestaurantTable source,
  ) async {
    final tables = context.read<TableBloc>().state.tables;
    final target = await showDialog<RestaurantTable>(
      context: context,
      builder: (_) => _TransferTableDialog(source: source, tables: tables),
    );
    if (target == null || !context.mounted) return;
    _pendingTargetName = target.name;
    context.read<DraftBloc>().add(
      DraftTransferRequested(
        sourceTableId: source.id,
        targetTableId: target.id,
      ),
    );
  }
}

class _FloorTableCard extends StatelessWidget {
  const _FloorTableCard({required this.table, this.openedAt, this.onTransfer});

  final RestaurantTable table;
  final DateTime? openedAt;
  final VoidCallback? onTransfer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = _statusColor(theme.colorScheme, table.status);
    final isReserved = table.status == TableStatus.reserved;
    return Semantics(
      container: true,
      label: '${table.name}, ${_statusLabel(l10n, table.status)}',
      enabled: !isReserved,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: color.withValues(alpha: isReserved ? 0.08 : 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.45)),
        ),
        child: InkWell(
          onLongPress: onTransfer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_restaurant_outlined, color: color),
                    const Spacer(),
                    if (onTransfer != null)
                      IconButton(
                        onPressed: onTransfer,
                        tooltip: l10n.transferTable,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: const Icon(Icons.more_vert),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  table.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _details(l10n, table),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusLabel(l10n, table.status),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                if (openedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(_elapsed(openedAt!), style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _details(AppLocalizations l10n, RestaurantTable table) {
    final details = <String>[];
    if (table.seats != null) details.add('${table.seats} ${l10n.tableSeats}');
    if (table.zone?.trim().isNotEmpty == true) details.add(table.zone!.trim());
    return details.join(' • ');
  }

  String _elapsed(DateTime openedAt) {
    final elapsed = DateTime.now().difference(openedAt);
    if (elapsed.isNegative) return '';
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '${hours}h ${minutes}m' : '${elapsed.inMinutes}m';
  }

  Color _statusColor(ColorScheme scheme, TableStatus status) =>
      switch (status) {
        TableStatus.available => scheme.primary,
        TableStatus.occupied => scheme.error,
        TableStatus.reserved => scheme.tertiary,
      };

  String _statusLabel(AppLocalizations l10n, TableStatus status) =>
      switch (status) {
        TableStatus.available => l10n.tableStatusAvailable,
        TableStatus.occupied => l10n.tableStatusOccupied,
        TableStatus.reserved => l10n.tableStatusReserved,
      };
}

class _TransferTableDialog extends StatelessWidget {
  const _TransferTableDialog({required this.source, required this.tables});

  final RestaurantTable source;
  final List<RestaurantTable> tables;

  @override
  Widget build(BuildContext context) {
    final targets = tables
        .where(
          (table) =>
              table.id != source.id && table.status == TableStatus.available,
        )
        .toList();
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.transferTable),
      content: SizedBox(
        width: 420,
        child: targets.isEmpty
            ? Text(l10n.noTransferTables)
            : ListView.separated(
                shrinkWrap: true,
                itemCount: targets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final target = targets[index];
                  return OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(target),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(target.name),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
