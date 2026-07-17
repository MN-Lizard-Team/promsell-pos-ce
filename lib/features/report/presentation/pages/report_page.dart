import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/shell/main_shell_scope.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';
import 'package:promsell_pos_ce/features/history/presentation/pages/history_tab_view.dart';
import 'package:promsell_pos_ce/features/report/domain/extensions/report_calculator.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/date_range_preset_chips.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_date_range_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_payment_method_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_promptpay_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_top_products_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/summary_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, this.initialTabIndex});

  final int? initialTabIndex;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ReportCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex?.clamp(0, 1) ?? 0,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _cubit = sl<ReportCubit>();
    // Predictable daily ritual: always open on today for this visit.
    _cubit.openToday();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onHistory = _tabController.index == 1;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            onHistory ? context.l10n.historyTitle : context.l10n.reportTitle,
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: const Icon(Icons.bar_chart),
                text: context.l10n.navReport,
              ),
              Tab(
                icon: const Icon(Icons.receipt_long),
                text: context.l10n.navHistory,
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const _ReportView(),
            // Seed History with ReportCubit range (SSOT under this shell).
            HistoryTabView(
              initialFrom: _cubit.state.from,
              initialTo: _cubit.state.to,
              syncWithReport: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView();

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

  void _openDailyClose(BuildContext context, DateTime? to) {
    final d = to ?? DateTime.now();
    final dateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(d.year, d.month, d.day));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DailyClosePage(date: dateStr)),
    );
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final appLocale = settings.locale.languageCode;
    final fmt = DateFormat(settings.dateFormat, appLocale);
    final todayRange = DateRangePresets.today();

    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        final cubit = context.read<ReportCubit>();
        final sales = state.sales;
        final from = state.from ?? todayRange.$1;
        final to = state.to ?? todayRange.$2;
        final totals = sales.periodTotals;
        final now = DateTime.now();
        final closeIsToday = _isSameCalendarDay(to, now);
        final closeLabel = closeIsToday
            ? context.l10n.closeDayToday
            : context.l10n.closeDayForDate(fmt.format(to));

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError && sales.isEmpty) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: context.l10n.errorOccurred,
            actionLabel: context.l10n.retry,
            onAction: cubit.load,
          );
        }

        if (sales.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => cubit.load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                DateRangePresetChips(
                  from: from,
                  to: to,
                  onPreset: cubit.changeDateRange,
                  onCustom: () => _pickRange(context, cubit, from, to),
                ),
                const SizedBox(height: 8),
                ReportDateRangeCard(
                  from: from,
                  to: to,
                  fmt: fmt,
                  onTap: () => _pickRange(context, cubit, from, to),
                ),
                const SizedBox(height: 48),
                AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: context.l10n.reportNoSalesInPeriod,
                  actionLabel: context.l10n.goToSale,
                  onAction: () => _goToSale(context),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => cubit.load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DateRangePresetChips(
                  from: from,
                  to: to,
                  onPreset: cubit.changeDateRange,
                  onCustom: () => _pickRange(context, cubit, from, to),
                ),
                const SizedBox(height: 8),
                ReportDateRangeCard(
                  from: from,
                  to: to,
                  fmt: fmt,
                  onTap: () => _pickRange(context, cubit, from, to),
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: context.l10n.netRevenue,
                  value: totals.netRevenue.value,
                  currency: settings.currency,
                  subtitle: context.l10n.salesCount(totals.salesCount),
                  icon: Icons.attach_money,
                  color: theme.colorScheme.primary,
                ),
                if (totals.voidCount > 0) ...[
                  const SizedBox(height: 8),
                  SummaryCard(
                    title: context.l10n.voidedTotal,
                    value: totals.voidedTotal.value,
                    currency: settings.currency,
                    subtitle: context.l10n.voidedSalesCount(totals.voidCount),
                    icon: Icons.block,
                    color: theme.colorScheme.error,
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openDailyClose(context, to),
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: Text(closeLabel),
                ),
                const SizedBox(height: 16),
                ReportPaymentMethodCard(
                  byMethod: totals.paymentBreakdown,
                  methodCounts: totals.paymentCounts,
                  netRevenue: totals.netRevenue.value,
                  currency: settings.currency,
                ),
                const SizedBox(height: 16),
                ReportPromptPayCard(
                  sales: sales,
                  currency: settings.currency,
                  fmt: fmt,
                ),
                const SizedBox(height: 16),
                ReportTopProductsCard(
                  topProducts: sales.topProductStats(),
                  currency: settings.currency,
                ),
              ],
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
