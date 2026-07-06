import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/history/presentation/pages/history_tab_view.dart';
import 'package:promsell_pos_ce/features/report/domain/extensions/report_calculator.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
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
    _cubit = sl<ReportCubit>();
    _cubit.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.reportTitle),
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
          children: const [_ReportView(), HistoryTabView()],
        ),
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final appLocale = settings.locale.languageCode;
    final fmt = DateFormat(settings.dateFormat, appLocale);

    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        final cubit = context.read<ReportCubit>();
        final sales = state.sales;
        final from =
            state.from ?? DateTime.now().subtract(const Duration(days: 30));
        final to = state.to ?? DateTime.now();

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError) {
          return AppEmptyState(
            icon: Icons.error_outline,
            title: context.l10n.errorOccurred,
            actionLabel: context.l10n.retry,
            onAction: cubit.load,
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
                ReportDateRangeCard(
                  from: from,
                  to: to,
                  fmt: fmt,
                  onTap: () => _pickRange(context, cubit, from, to),
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: context.l10n.netRevenue,
                  value: sales.netRevenue,
                  currency: settings.currency,
                  subtitle: context.l10n.salesCount(
                    sales.completedSales.length,
                  ),
                  icon: Icons.attach_money,
                  color: theme.colorScheme.primary,
                ),
                if (sales.voidedSales.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SummaryCard(
                    title: context.l10n.voidedTotal,
                    value: sales.voidedTotal,
                    currency: settings.currency,
                    subtitle: context.l10n.voidedSalesCount(
                      sales.voidedSales.length,
                    ),
                    icon: Icons.block,
                    color: theme.colorScheme.error,
                  ),
                ],
                const SizedBox(height: 16),
                ReportPaymentMethodCard(
                  byMethod: sales.byPaymentMethod(),
                  currency: settings.currency,
                ),
                const SizedBox(height: 16),
                ReportPromptPayCard(
                  sales: sales,
                  currency: settings.currency,
                  fmt: fmt,
                ),
                const SizedBox(height: 16),
                ReportTopProductsCard(topProducts: sales.topProducts()),
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
        range.start,
        range.end.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999),
      );
    }
  }
}
