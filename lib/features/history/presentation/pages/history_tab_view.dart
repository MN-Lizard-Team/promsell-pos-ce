import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/shell/main_shell_scope.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/history/presentation/utils/history_error_display.dart';
import 'package:promsell_pos_ce/features/history/presentation/widgets/tiles/sale_expansion_tile.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/date_range_preset_chips.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Sale history list. When [syncWithReport] is true (Report shell), period
/// follows [ReportCubit] SSOT and chips update both loaders.
class HistoryTabView extends StatelessWidget {
  const HistoryTabView({
    super.key,
    this.initialFrom,
    this.initialTo,
    this.syncWithReport = false,
  });

  final DateTime? initialFrom;
  final DateTime? initialTo;

  /// When true, expect [ReportCubit] above and keep ranges aligned.
  final bool syncWithReport;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final today = DateRangePresets.today();
        final from = initialFrom ?? today.$1;
        final to = initialTo ?? today.$2;
        return HistoryBloc(
          watchSaleHistory: sl<WatchSaleHistory>(),
          voidSale: sl<VoidSale>(),
        )..add(HistoryDateRangeChanged(from: from, to: to));
      },
      child: _HistoryTabContent(syncWithReport: syncWithReport),
    );
  }
}

class _HistoryTabContent extends StatelessWidget {
  const _HistoryTabContent({required this.syncWithReport});

  final bool syncWithReport;

  void _applyRange(BuildContext context, DateTime from, DateTime to) {
    context.read<HistoryBloc>().add(
      HistoryDateRangeChanged(from: from, to: to),
    );
    if (syncWithReport) {
      context.read<ReportCubit>().changeDateRange(from, to);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final dateFmt = DateFormat(
      settings.dateFormat,
      settings.locale.languageCode,
    );
    final fmt = DateFormat(
      '${settings.dateFormat} HH:mm',
      settings.locale.languageCode,
    );

    Widget body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: SearchBar(
            hintText: context.l10n.searchHistoryHint,
            leading: const Icon(Icons.search),
            onChanged: (q) =>
                context.read<HistoryBloc>().add(HistorySearchChanged(q)),
          ),
        ),
        BlocBuilder<HistoryBloc, HistoryState>(
          buildWhen: (p, c) => p.from != c.from || p.to != c.to,
          builder: (context, state) {
            final from = state.from ?? DateRangePresets.today().$1;
            final to = state.to ?? DateRangePresets.today().$2;
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DateRangePresetChips(
                    from: from,
                    to: to,
                    onPreset: (f, t) => _applyRange(context, f, t),
                    onCustom: () => _pickRange(context),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${dateFmt.format(from)} – ${dateFmt.format(to)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: Stack(
            children: [
              MultiBlocListener(
                listeners: [
                  BlocListener<HistoryBloc, HistoryState>(
                    listenWhen: (prev, curr) =>
                        prev.voidingSaleId != null &&
                        curr.voidingSaleId == null &&
                        (curr.errorMessage == null ||
                            curr.errorMessage!.isEmpty),
                    listener: (ctx, state) {
                      AppSnackBar.success(ctx, ctx.l10n.voidSuccess);
                    },
                  ),
                  BlocListener<HistoryBloc, HistoryState>(
                    listenWhen: (prev, curr) =>
                        prev.voidingSaleId != null &&
                        curr.voidingSaleId == null &&
                        curr.errorMessage != null &&
                        curr.errorMessage!.isNotEmpty,
                    listener: (ctx, state) {
                      AppSnackBar.error(
                        ctx,
                        historyErrorMessage(ctx.l10n, state.errorMessage),
                      );
                    },
                  ),
                ],
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (ctx, state) {
                    if (state.status == HistoryStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == HistoryStatus.failure &&
                        state.sales.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.error_outline,
                        title: state.errorMessage ?? ctx.l10n.errorOccurred,
                        actionLabel: ctx.l10n.retry,
                        onAction: () => ctx.read<HistoryBloc>().add(
                          const HistorySubscribed(),
                        ),
                      );
                    }
                    final filtered = state.filteredSales;
                    if (filtered.isEmpty) {
                      final searching = state.searchQuery.trim().isNotEmpty;
                      return AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: searching
                            ? ctx.l10n.noSearchResults
                            : ctx.l10n.noSalesYet,
                        actionLabel: searching
                            ? ctx.l10n.clearSearch
                            : ctx.l10n.goToSale,
                        onAction: searching
                            ? () => ctx.read<HistoryBloc>().add(
                                const HistorySearchChanged(''),
                              )
                            : () => _goToSale(ctx),
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
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final sale = filtered[i];
                          return SaleExpansionTile(
                            sale: sale,
                            dateFormat: fmt.format(sale.createdAt),
                            isVoiding: state.voidingSaleId == sale.id,
                            voidBusy: state.voidingSaleId != null,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => _openDailyClose(context),
                  heroTag: 'history_close_day_fab',
                  icon: const Icon(Icons.lock_outline),
                  label: Text(context.l10n.closeDay),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!syncWithReport) return body;

    // ReportCubit SSOT → History when Report chips/picker change.
    return BlocListener<ReportCubit, ReportState>(
      listenWhen: (p, c) => p.from != c.from || p.to != c.to,
      listener: (ctx, s) {
        final from = s.from;
        final to = s.to;
        if (from == null || to == null) return;
        final h = ctx.read<HistoryBloc>().state;
        if (h.from == from && h.to == to) return;
        ctx.read<HistoryBloc>().add(
          HistoryDateRangeChanged(from: from, to: to),
        );
      },
      child: body,
    );
  }

  /// Close the end day of the active History filter (`to`), not device "today".
  void _openDailyClose(BuildContext context) {
    final state = context.read<HistoryBloc>().state;
    final d = state.to ?? state.from ?? DateTime.now();
    final dateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(d.year, d.month, d.day));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DailyClosePage(date: dateStr)),
    );
  }

  void _goToSale(BuildContext context) {
    final shell = MainShellScope.maybeOf(context);
    if (shell != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      shell.goToTab(2);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final state = context.read<HistoryBloc>().state;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: state.from ?? DateRangePresets.today().$1,
        end: state.to ?? DateRangePresets.today().$2,
      ),
    );
    if (range != null && context.mounted) {
      _applyRange(
        context,
        DateRangePresets.startOfDay(range.start),
        DateRangePresets.endOfDay(range.end),
      );
    }
  }
}
