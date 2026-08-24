import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/utils/report_navigation.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_date_filter_header.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_overview_content.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_skeleton.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Report overview body — extracted from `_ReportView` for readability.
///
/// Renders date chrome, summary cards, charts, top products, PromptPay,
/// and close-day CTA inside a single scrollable column with stagger animation.
class ReportOverviewBody extends StatelessWidget {
  const ReportOverviewBody({super.key});

  bool _isSameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daySpan(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    return b.difference(a).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final appLocale = settings.localeCode;
    final fmt = DateFormat(settings.dateFormat, appLocale);
    final todayRange = DateRangePresets.today();
    final calculator = sl<ReportCalculatorService>();

    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        final cubit = context.read<ReportCubit>();
        final sales = state.sales;
        final aggregate = state.aggregate;
        final from = state.from ?? todayRange.$1;
        final to = state.to ?? todayRange.$2;
        // SQL-aggregate path (long ranges): totals come precomputed and the
        // hydrated list is intentionally empty.
        final totals = aggregate?.totals ?? calculator.periodTotals(sales);
        final now = DateTime.now();
        final closeIsToday = _isSameCalendarDay(to, now);
        final closeLabel = closeIsToday
            ? context.l10n.closeDayToday
            : context.l10n.closeDayForDate(fmt.format(to));
        final days = _daySpan(from, to);
        final dateHeader = ReportDateFilterHeader(
          from: from,
          to: to,
          fmt: fmt,
          onPreset: cubit.changeDateRange,
          onPick: () => _pickRange(context, cubit, from, to),
          compact: true,
        );
        if (state.isLoading && sales.isEmpty && aggregate == null) {
          return _ReportLoadingState(
            dateHeader: dateHeader,
            onClear: cubit.openToday,
          );
        }

        if (state.hasError && sales.isEmpty && aggregate == null) {
          return _ReportErrorState(
            dateHeader: dateHeader,
            onRetry: cubit.load,
            onClear: cubit.openToday,
          );
        }

        if (state.isEmpty) {
          return _ReportEmptyState(
            dateHeader: dateHeader,
            onClear: cubit.openToday,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => cubit.load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: ReportOverviewContent(
              dateHeader: dateHeader,
              totals: totals,
              sales: sales,
              previousPeriodNetRevenue: aggregate != null
                  ? (state.previousSummary?.netRevenue.value ?? 0)
                  : calculator
                        .periodTotals(state.previousSales)
                        .netRevenue
                        .value,
              dailyRevenue: state.dailyRevenue,
              days: days,
              currency: settings.currency,
              fmt: fmt,
              closeLabel: closeLabel,
              onCloseDay: () => ReportNavigation.openDailyClose(context, to),
              profit: state.profit,
              previousProfit: state.previousProfit,
              productLookup: state.productLookup,
              calculator: calculator,
              lastUpdated: state.lastUpdated,
              aggregate: aggregate,
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickRange(
    BuildContext context,
    ReportCubit cubit,
    DateTime from,
    DateTime to,
  ) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: from, end: to),
    );
    if (range != null) {
      cubit.changeDateRange(
        DateRangePresets.startOfDay(range.start),
        DateRangePresets.endOfDay(range.end),
      );
    }
  }
}

/// Loading state — date header + skeleton cards.
class _ReportLoadingState extends StatelessWidget {
  const _ReportLoadingState({required this.dateHeader, required this.onClear});

  final Widget dateHeader;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ReportSkeleton(dateHeader: dateHeader);
  }
}

/// Error state — date header + quiet retry.
class _ReportErrorState extends StatelessWidget {
  const _ReportErrorState({
    required this.dateHeader,
    required this.onRetry,
    required this.onClear,
  });

  final Widget dateHeader;
  final VoidCallback onRetry;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        dateHeader,
        const SizedBox(height: 80),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  TablerIcons.alertTriangle,
                  size: 52,
                  color: scheme.error.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.errorOccurred,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.reportErrorDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.primary.withValues(alpha: 0.7),
                  ),
                  child: Text(
                    l10n.retry,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ClearFilterButton(onClear: onClear),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state — date header + quiet placeholder.
class _ReportEmptyState extends StatelessWidget {
  const _ReportEmptyState({required this.dateHeader, required this.onClear});

  final Widget dateHeader;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        dateHeader,
        const SizedBox(height: 80),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  TablerIcons.receiptOff,
                  size: 56,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.reportNoSalesInPeriod,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.reportEmptyDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                _ClearFilterButton(onClear: onClear),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Quiet "clear filter" button — resets date range to today.
class _ClearFilterButton extends StatelessWidget {
  const _ClearFilterButton({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    final actionColor = scheme.onSurfaceVariant.withValues(alpha: 0.92);

    return OutlinedButton.icon(
      onPressed: onClear,
      style: OutlinedButton.styleFrom(
        foregroundColor: actionColor,
        backgroundColor: scheme.surfaceContainerLow.withValues(alpha: 0.55),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.28)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(0, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(TablerIcons.filterX, size: 18),
      label: Text(
        l10n.clearFilters,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: actionColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
