import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportView();
  }
}

class _ReportView extends StatefulWidget {
  const _ReportView();

  @override
  State<_ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<_ReportView> {
  late final WatchReport _watchReport = sl<WatchReport>();
  List<Sale> _sales = [];
  bool _loading = true;
  bool _hasError = false;
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  StreamSubscription<List<Sale>>? _sub;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    _sub?.cancel();
    _sub = _watchReport(from: _from, to: _to).listen(
      (sales) {
        if (!mounted) return;
        setState(() {
          _sales = sales;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
          _loading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  double get _totalRevenue =>
      _sales.fold(0.0, (sum, s) => sum + s.totalAmount);

  Map<String, double> get _byMethod {
    final map = <String, double>{};
    for (final s in _sales) {
      final key = normalizePaymentMethod(s.paymentMethod);
      map[key] = (map[key] ?? 0) + s.totalAmount;
    }
    return map;
  }

  Map<String, int> get _topProducts {
    final map = <String, int>{};
    for (final s in _sales) {
      for (final item in s.items) {
        map[item.productName] = (map[item.productName] ?? 0) + item.qty;
      }
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final appLocale = settings.locale.languageCode;
    final fmt = DateFormat(settings.dateFormat, appLocale);
    final moneyFmt = NumberFormat('#,##0.00', appLocale);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reportTitle),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text('${fmt.format(_from)} – ${fmt.format(_to)}'),
            onPressed: _pickRange,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text(context.l10n.errorOccurred))
              : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryCard(
                    title: context.l10n.totalRevenue,
                    value: '${settings.currency}${moneyFmt.format(_totalRevenue)}',
                    subtitle: context.l10n.salesCount(_sales.length),
                    icon: Icons.attach_money,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.byPaymentMethod,
                              style: theme.textTheme.titleSmall),
                          const SizedBox(height: 12),
                          ..._byMethod.entries.map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(localizePaymentMethod(context, e.key)),
                                    Text('${settings.currency}${moneyFmt.format(e.value)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )),
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
                          Text(context.l10n.topProducts,
                              style: theme.textTheme.titleSmall),
                          const SizedBox(height: 12),
                          ..._topProducts.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final rank = entry.key + 1;
                            final e = entry.value;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text('$rank.',
                                        style: theme.textTheme.bodySmall),
                                  ),
                                  Expanded(child: Text(e.key)),
                                  Text(context.l10n.units(e.value),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
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

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (!mounted) return;
    if (range != null) {
      _from = range.start;
      _to = range.end.copyWith(
          hour: 23, minute: 59, second: 59, millisecond: 999);
      _startListening();
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                Text(value,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold, color: color)),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
