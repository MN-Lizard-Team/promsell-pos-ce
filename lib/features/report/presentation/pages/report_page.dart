import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/report/domain/extensions/report_calculator.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_date_range_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_payment_method_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_top_products_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/summary_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final ReportCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ReportCubit>();
    _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _cubit, child: const _ReportView());
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

        Widget body;
        if (state.isLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (state.hasError) {
          body = AppEmptyState(
            icon: Icons.error_outline,
            title: context.l10n.errorOccurred,
            actionLabel: context.l10n.retry,
            onAction: cubit.load,
          );
        } else {
          body = RefreshIndicator(
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
                  ReportTopProductsCard(topProducts: sales.topProducts()),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.reportTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () => _pickRange(context, cubit, from, to),
              ),
            ],
          ),
          body: body,
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
