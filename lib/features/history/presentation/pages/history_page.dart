import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';

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
        return HistoryBloc(watchSaleHistory: sl<WatchSaleHistory>())
          ..add(HistoryDateRangeChanged(from: from, to: to));
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.historyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _pickRange(context),
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (ctx, state) {
          if (state.status == HistoryStatus.loading) {
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
          if (state.sales.isEmpty) {
            return AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: ctx.l10n.noSalesYet,
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
              itemCount: state.sales.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final sale = state.sales[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: MoneyText(
                      value: sale.totalAmount,
                      currency: settings.currency,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    subtitle: Text(
                      '#${sale.id}  •  ${fmt.format(sale.createdAt)}  •  ${localizePaymentMethod(ctx, sale.paymentMethod)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    children: [
                      ...sale.items.map(
                        (item) => ListTile(
                          dense: true,
                          title: Text(item.productName),
                          subtitle: Text(
                            '${item.qty} × ${settings.currency}${item.price.toStringAsFixed(2)}',
                          ),
                          trailing: MoneyText(
                            value: item.subtotal,
                            currency: settings.currency,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (sale.note != null && sale.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            ctx.l10n.noteLabel(sale.note!),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
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
