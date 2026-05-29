import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
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
                  Card(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    child: InkWell(
                      onTap: () => _pickRange(context, cubit, from, to),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${fmt.format(from)} – ${fmt.format(to)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: context.l10n.netRevenue,
                    value: _netRevenue(sales),
                    currency: settings.currency,
                    subtitle: context.l10n.salesCount(
                      _completedSales(sales).length,
                    ),
                    icon: Icons.attach_money,
                    color: theme.colorScheme.primary,
                  ),
                  if (_voidedSales(sales).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _SummaryCard(
                      title: context.l10n.voidedTotal,
                      value: _voidedTotal(sales),
                      currency: settings.currency,
                      subtitle: context.l10n.voidedSalesCount(
                        _voidedSales(sales).length,
                      ),
                      icon: Icons.block,
                      color: theme.colorScheme.error,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.byPaymentMethod,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          if (_byMethod(sales).isEmpty)
                            AppEmptyState(
                              icon: Icons.payments_outlined,
                              title: context.l10n.noSalesYet,
                            )
                          else
                            ..._byMethod(sales).entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(localizePaymentMethod(context, e.key)),
                                    MoneyText(
                                      value: e.value,
                                      currency: settings.currency,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.topProducts,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          if (_topProducts(sales).isEmpty)
                            AppEmptyState(
                              icon: Icons.leaderboard_outlined,
                              title: context.l10n.noSalesYet,
                            )
                          else
                            ..._topProducts(
                              sales,
                            ).entries.toList().asMap().entries.map((entry) {
                              final rank = entry.key + 1;
                              final e = entry.value;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      child: Text(
                                        '$rank',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(e.key)),
                                    Text(
                                      context.l10n.units(e.value),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
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

  List<Sale> _completedSales(List<Sale> sales) =>
      sales.where((s) => !s.isVoided).toList();

  List<Sale> _voidedSales(List<Sale> sales) =>
      sales.where((s) => s.isVoided).toList();

  double _netRevenue(List<Sale> sales) =>
      _completedSales(sales).fold(0.0, (sum, s) => sum + s.totalAmount);

  double _voidedTotal(List<Sale> sales) =>
      _voidedSales(sales).fold(0.0, (sum, s) => sum + s.totalAmount);

  Map<String, double> _byMethod(List<Sale> sales) {
    final map = <String, double>{};
    for (final s in _completedSales(sales)) {
      final key = normalizePaymentMethod(s.paymentMethod);
      map[key] = (map[key] ?? 0) + s.totalAmount;
    }
    return map;
  }

  Map<String, int> _topProducts(List<Sale> sales) {
    final qtyById = <String, int>{};
    final nameById = <String, String>{};
    for (final s in _completedSales(sales)) {
      for (final item in s.items) {
        nameById[item.productId] = item.productName;
        qtyById[item.productId] = (qtyById[item.productId] ?? 0) + item.qty;
      }
    }
    final sorted = qtyById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(
      sorted.take(5).map((e) => MapEntry(nameById[e.key] ?? e.key, e.value)),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.currency,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final double value;
  final String currency;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall),
                  MoneyText(
                    value: value,
                    currency: currency,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    color: color,
                  ),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
