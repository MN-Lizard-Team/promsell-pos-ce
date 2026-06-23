import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';
import 'package:promsell_pos_ce/features/history/presentation/widgets/sale_expansion_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final now = DateTime.now();
        final from = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 30));
        final to = now.copyWith(
          hour: 23,
          minute: 59,
          second: 59,
          millisecond: 999,
        );
        return HistoryBloc(
          watchSaleHistory: sl<WatchSaleHistory>(),
          voidSale: sl<VoidSale>(),
        )..add(HistoryDateRangeChanged(from: from, to: to));
      },
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final fmt = DateFormat(
      '${settings.dateFormat} HH:mm',
      settings.locale.languageCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.historyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _pickRange(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SearchBar(
              hintText: context.l10n.searchHistoryHint,
              leading: const Icon(Icons.search),
              onChanged: (q) =>
                  context.read<HistoryBloc>().add(HistorySearchChanged(q)),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DailyClosePage(date: today)),
          );
        },
        heroTag: 'history_close_day_fab',
        icon: const Icon(Icons.lock_outline),
        label: Text(context.l10n.closeDay),
      ),
      body: BlocListener<HistoryBloc, HistoryState>(
        listenWhen: (prev, curr) =>
            (curr.status == HistoryStatus.success &&
                prev.status == HistoryStatus.voiding) ||
            (curr.status == HistoryStatus.failure &&
                prev.status == HistoryStatus.voiding),
        listener: (ctx, state) {
          if (state.status == HistoryStatus.success) {
            AppSnackBar.success(ctx, ctx.l10n.voidSuccess);
          } else if (state.status == HistoryStatus.failure) {
            AppSnackBar.error(
              ctx,
              state.errorMessage ?? ctx.l10n.errorOccurred,
            );
          }
        },
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (ctx, state) {
            if (state.status == HistoryStatus.loading ||
                state.status == HistoryStatus.voiding) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == HistoryStatus.failure) {
              return AppEmptyState(
                icon: Icons.error_outline,
                title: state.errorMessage ?? ctx.l10n.errorOccurred,
                actionLabel: ctx.l10n.retry,
                onAction: () =>
                    ctx.read<HistoryBloc>().add(const HistorySubscribed()),
              );
            }
            final filtered = state.filteredSales;
            if (filtered.isEmpty) {
              return AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: state.searchQuery.isNotEmpty
                    ? ctx.l10n.noSearchResults
                    : ctx.l10n.noSalesYet,
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                final bloc = ctx.read<HistoryBloc>();
                bloc.add(const HistorySubscribed());
                await bloc.stream.firstWhere(
                  (s) =>
                      s.status == HistoryStatus.success ||
                      s.status == HistoryStatus.failure,
                );
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => SaleExpansionTile(
                  sale: filtered[i],
                  dateFormat: fmt.format(filtered[i].createdAt),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final state = context.read<HistoryBloc>().state;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: state.from ?? now.subtract(const Duration(days: 30)),
        end: state.to ?? now,
      ),
    );
    if (range != null && context.mounted) {
      context.read<HistoryBloc>().add(
        HistoryDateRangeChanged(
          from: range.start,
          to: range.end.copyWith(
            hour: 23,
            minute: 59,
            second: 59,
            millisecond: 999,
          ),
        ),
      );
    }
  }
}
