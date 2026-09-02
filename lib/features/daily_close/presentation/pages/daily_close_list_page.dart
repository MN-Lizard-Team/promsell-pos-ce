import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_list.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class DailyCloseListPage extends StatefulWidget {
  const DailyCloseListPage({super.key});

  @override
  State<DailyCloseListPage> createState() => _DailyCloseListPageState();
}

class _DailyCloseListPageState extends State<DailyCloseListPage> {
  late Future<List<DailyClose>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<DailyClose>> _load() => sl<GetDailyCloseList>().call();

  void _reload() {
    setState(() => _future = _load());
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  void _openDate(String date) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DailyClosePage(date: date)),
    ).then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyCloseHistoryTitle)),
      body: FutureBuilder<List<DailyClose>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && !snapshot.hasData) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: l10n.errorOccurred,
              message: l10n.dailyCloseLoadError(''),
              actionLabel: l10n.retry,
              onAction: _reload,
            );
          }

          final records = snapshot.data ?? const <DailyClose>[];
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final hasToday = records.any((item) => item.closeDate == today);
          final children = <Widget>[
            if (!hasToday)
              _OpenTodayTile(date: today, onTap: () => _openDate(today)),
            ...records.map(
              (item) => _DailyCloseHistoryTile(
                item: item,
                onTap: () => _openDate(item.closeDate),
              ),
            ),
          ];

          if (children.isEmpty) {
            return AppEmptyState(
              icon: Icons.lock_clock_outlined,
              title: l10n.noDailyClosesYet,
              actionLabel: l10n.closeToday,
              onAction: () => _openDate(today),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              children: children,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          _openDate(today);
        },
        heroTag: 'daily_close_list_fab',
        icon: const Icon(Icons.lock_outline),
        label: Text(context.l10n.closeToday),
      ),
    );
  }
}

class _OpenTodayTile extends StatelessWidget {
  const _OpenTodayTile({required this.date, required this.onTap});
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final formatted = DateFormat.yMMMd().format(DateTime.parse(date));
    return Semantics(
      button: true,
      label: '$formatted, ${l10n.dailyCloseStatusOpen}',
      hint: l10n.closeToday,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            child: const Icon(Icons.lock_open_outlined),
          ),
          title: Text(formatted),
          subtitle: Text(l10n.dailyCloseStatusOpen),
          trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _DailyCloseHistoryTile extends StatelessWidget {
  const _DailyCloseHistoryTile({required this.item, required this.onTap});
  final DailyClose item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final formatted = DateFormat.yMMMd().format(DateTime.parse(item.closeDate));
    final currency = _currency(context);
    final variance = item.overShortAmount.value;
    final varianceText = variance > 0
        ? l10n.dailyCloseOverAmount(_amount(currency, variance.abs()))
        : variance < 0
        ? l10n.dailyCloseShortAmount(_amount(currency, variance.abs()))
        : l10n.dailyCloseNoMismatch;
    final varianceColor = variance > 0
        ? scheme.tertiary
        : variance < 0
        ? scheme.error
        : scheme.primary;

    return Semantics(
      button: true,
      label: '$formatted, ${l10n.dailyCloseStatusClosed}, $varianceText',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: Text('${item.salesCount}'),
          ),
          title: Text(formatted),
          subtitle: Text(
            '${l10n.dailyCloseSales(item.salesCount)}  ·  '
            '${l10n.dailyCloseVoids(item.voidCount)}',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MoneyText(value: item.totalRevenue.value, currency: currency),
              Text(
                varianceText,
                style: TextStyle(color: varianceColor, fontSize: 12),
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  String _amount(String currency, double value) =>
      '$currency${value.toStringAsFixed(2)}';

  String _currency(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.settings.currency;
    } catch (_) {
      return '฿';
    }
  }
}
