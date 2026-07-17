import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_cubit.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/inventory_log_row.dart';

class InventoryLogPage extends StatelessWidget {
  const InventoryLogPage({super.key, this.productId});
  final String? productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InventoryLogCubit(watchInventoryLogs: sl<WatchInventoryLogs>())
            ..load(productId: productId),
      child: _InventoryLogView(productId: productId),
    );
  }
}

class _InventoryLogView extends StatelessWidget {
  const _InventoryLogView({this.productId});
  final String? productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.inventoryLog)),
      body: BlocBuilder<InventoryLogCubit, InventoryLogState>(
        builder: (context, state) {
          if (state.status == InventoryLogStatus.loading ||
              state.status == InventoryLogStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == InventoryLogStatus.failure) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: state.errorMessage ?? context.l10n.errorOccurred,
              actionLabel: context.l10n.retry,
              onAction: () =>
                  context.read<InventoryLogCubit>().load(productId: productId),
            );
          }
          if (state.logs.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.noInventoryLogs,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: state.logs.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (_, i) => InventoryLogRow(log: state.logs[i]),
          );
        },
      ),
    );
  }
}
