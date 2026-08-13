import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/inventory/data/datasources/inventory_log_local_datasource.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_cubit.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/inventory_log_row.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.productId,
    required this.watchInventoryLogs,
  });

  final String productId;
  final WatchInventoryLogs watchInventoryLogs;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InventoryLogCubit(watchInventoryLogs: watchInventoryLogs)
            ..load(productId: productId),
      child: _HistoryTabView(productId: productId),
    );
  }
}

class _HistoryTabView extends StatelessWidget {
  const _HistoryTabView({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<InventoryLogCubit, InventoryLogState>(
      builder: (context, state) {
        if (state.status == InventoryLogStatus.loading ||
            state.status == InventoryLogStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == InventoryLogStatus.failure) {
          return AppEmptyState(
            icon: TablerIcons.alertCircle,
            title: state.errorMessage ?? l10n.errorOccurred,
            actionLabel: l10n.retry,
            onAction: () =>
                context.read<InventoryLogCubit>().load(productId: productId),
          );
        }
        if (state.logs.isEmpty) {
          return AppEmptyState(
            icon: TablerIcons.history,
            title: l10n.productNoHistory,
          );
        }

        final capped =
            state.logs.length >= InventoryLogLocalDatasource.productLogLimit;

        return ListView.separated(
          padding: productPreviewTabPadding,
          // +1 for section header card
          itemCount: state.logs.length + 1,
          separatorBuilder: (_, index) {
            if (index == 0) return const SizedBox(height: 8);
            return Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            );
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return PreviewCard(
                icon: TablerIcons.history,
                title: l10n.productTabHistory,
                child: capped
                    ? Text(
                        l10n.productHistoryShowingLatest(
                          InventoryLogLocalDatasource.productLogLimit,
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Text(
                        l10n.cartItemCount(state.logs.length),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              );
            }
            final log = state.logs[index - 1];
            return Material(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              child: InventoryLogRow(log: log),
            );
          },
        );
      },
    );
  }
}
