import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/history/presentation/utils/history_error_display.dart';
import 'package:promsell_pos_ce/features/history/presentation/widgets/tiles/sale_expansion_tile.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/custom_range_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/date_filter_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/utils/report_navigation.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/close_day_cta.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_date_filter_header.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Sale history list. When [syncWithReport] is true (Report shell), period
/// follows [ReportCubit] SSOT and chips update both loaders.
class HistoryTabView extends StatelessWidget {
  const HistoryTabView({
    super.key,
    this.initialFrom,
    this.initialTo,
    this.syncWithReport = false,
    this.historyBloc,
  });

  final DateTime? initialFrom;
  final DateTime? initialTo;

  /// When true, expect [ReportCubit] above and keep ranges aligned.
  final bool syncWithReport;

  /// Reuses the shell-owned bloc when History is embedded in Report.
  final HistoryBloc? historyBloc;

  @override
  Widget build(BuildContext context) {
    final child = _HistoryTabContent(syncWithReport: syncWithReport);
    final bloc = historyBloc;
    if (bloc != null) {
      return BlocProvider.value(value: bloc, child: child);
    }

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
      child: child,
    );
  }
}

class _HistoryTabContent extends StatefulWidget {
  const _HistoryTabContent({required this.syncWithReport});

  final bool syncWithReport;

  @override
  State<_HistoryTabContent> createState() => _HistoryTabContentState();
}

class _HistoryTabContentState extends State<_HistoryTabContent>
    with AutomaticKeepAliveClientMixin<_HistoryTabContent> {
  @override
  bool get wantKeepAlive => true;

  void _applyRange(BuildContext context, DateTime from, DateTime to) {
    context.read<HistoryBloc>().add(
      HistoryDateRangeChanged(from: from, to: to),
    );
    if (widget.syncWithReport) {
      context.read<ReportCubit>().changeDateRange(from, to);
    }
  }

  Future<void> _openDateFilter(BuildContext context) async {
    final bloc = context.read<HistoryBloc>();
    final state = bloc.state;
    final dateFmt = DateFormat(
      context.watch<SettingsCubit>().state.settings.dateFormat,
    );
    final from = state.from ?? DateRangePresets.today().$1;
    final to = state.to ?? DateRangePresets.today().$2;
    final result = await DateFilterPage.show(
      context,
      from: from,
      to: to,
      fmt: dateFmt,
    );
    if (result == null || !context.mounted) return;
    if (result.from != null && result.to != null) {
      _applyRange(context, result.from!, result.to!);
    } else if (result.isCustom) {
      final custom = await CustomRangePage.show(
        context,
        initialFrom: from,
        initialTo: to,
        fmt: dateFmt,
      );
      if (custom != null && context.mounted) {
        _applyRange(context, custom.$1, custom.$2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final dateFmt = DateFormat(settings.dateFormat, settings.localeCode);
    final fmt = DateFormat('${settings.dateFormat} HH:mm', settings.localeCode);

    Widget body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: BlocBuilder<HistoryBloc, HistoryState>(
            buildWhen: (p, c) => p.from != c.from || p.to != c.to,
            builder: (context, state) {
              final from = state.from ?? DateRangePresets.today().$1;
              final to = state.to ?? DateRangePresets.today().$2;
              return ReportDateFilterHeader(
                from: from,
                to: to,
                fmt: dateFmt,
                onPreset: (f, t) => _applyRange(context, f, t),
                onPick: () async {
                  final result = await CustomRangePage.show(
                    context,
                    initialFrom: from,
                    initialTo: to,
                    fmt: dateFmt,
                  );
                  if (result != null && context.mounted) {
                    _applyRange(context, result.$1, result.$2);
                  }
                },
                compact: false,
              );
            },
          ),
        ),
        Expanded(
          child: MultiBlocListener(
            listeners: [
              BlocListener<HistoryBloc, HistoryState>(
                listenWhen: (prev, curr) =>
                    prev.voidingSaleId != null &&
                    curr.voidingSaleId == null &&
                    (curr.errorMessage == null || curr.errorMessage!.isEmpty),
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
                  return _HistoryStateBody(
                    dateHeader: _buildDateHeader(ctx, state, dateFmt),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(ctx).colorScheme.primary,
                        semanticsLabel: ctx.l10n.loading,
                      ),
                    ),
                  );
                }
                if (state.status == HistoryStatus.failure &&
                    state.sales.isEmpty) {
                  return _HistoryStateBody(
                    dateHeader: _buildDateHeader(ctx, state, dateFmt),
                    child: AppEmptyState(
                      icon: TablerIcons.alertCircle,
                      title: state.errorMessage ?? ctx.l10n.errorOccurred,
                      actionLabel: ctx.l10n.retry,
                      onAction: () => ctx.read<HistoryBloc>().add(
                        const HistorySubscribed(),
                      ),
                    ),
                  );
                }
                final filtered = state.filteredSales;
                if (filtered.isEmpty) {
                  final todayRange = DateRangePresets.today();
                  final isTodayRange =
                      state.from != null &&
                      state.to != null &&
                      state.from!.isAtSameMomentAs(todayRange.$1) &&
                      state.to!.isAtSameMomentAs(todayRange.$2);
                  return _HistoryStateBody(
                    dateHeader: _buildDateHeader(ctx, state, dateFmt),
                    child: AppEmptyState(
                      icon: TablerIcons.receiptOff,
                      title: isTodayRange
                          ? ctx.l10n.noSalesYet
                          : ctx.l10n.noSalesInRange,
                      actionLabel: isTodayRange
                          ? ctx.l10n.goToSale
                          : ctx.l10n.changeDateRange,
                      onAction: isTodayRange
                          ? () => ReportNavigation.goToSale(ctx)
                          : () => _openDateFilter(ctx),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: Theme.of(ctx).colorScheme.primary,
                        onRefresh: () async {
                          final bloc = ctx.read<HistoryBloc>();
                          bloc.add(const HistorySubscribed());
                          await bloc.stream
                              .firstWhere(
                                (s) =>
                                    s.status == HistoryStatus.success ||
                                    s.status == HistoryStatus.failure,
                              )
                              .timeout(const Duration(seconds: 10));
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final sale = filtered[i];
                            return SaleExpansionTile(
                              key: ValueKey(sale.id),
                              sale: sale,
                              dateFormat: fmt.format(sale.createdAt),
                              isVoiding: state.voidingSaleId == sale.id,
                              voidBusy: state.voidingSaleId != null,
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: CloseDayCta(
                        style: CloseDayCtaStyle.button,
                        heroTag: 'history_close_day',
                        label: ctx.l10n.closeDay,
                        onPressed: () async {
                          final s = ctx.read<HistoryBloc>().state;
                          final d = s.to ?? s.from ?? DateTime.now();
                          await ReportNavigation.openDailyClose(ctx, d);
                          if (ctx.mounted) {
                            ctx.read<HistoryBloc>().add(
                              const HistorySubscribed(),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );

    final responsiveBody = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: body,
      ),
    );

    if (!widget.syncWithReport) return responsiveBody;

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
      child: responsiveBody,
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    HistoryState state,
    DateFormat dateFmt,
  ) {
    final from = state.from ?? DateRangePresets.today().$1;
    final to = state.to ?? DateRangePresets.today().$2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Text(
        '${dateFmt.format(from)}${context.l10n.dateRangeSeparator}${dateFmt.format(to)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Wrapper that shows the date range context above loading/error/empty states.
class _HistoryStateBody extends StatelessWidget {
  const _HistoryStateBody({required this.dateHeader, required this.child});

  final Widget dateHeader;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        dateHeader,
        Expanded(child: child),
      ],
    );
  }
}
