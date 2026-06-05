import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/cubit/daily_close_cubit.dart';
import 'package:intl/intl.dart';

class DailyClosePage extends StatefulWidget {
  const DailyClosePage({super.key, this.date});
  final String? date;

  @override
  State<DailyClosePage> createState() => _DailyClosePageState();
}

class _DailyClosePageState extends State<DailyClosePage> {
  late final DailyCloseCubit _cubit;
  late final String _date;
  final _countedController = TextEditingController();
  final _openingController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = sl<DailyCloseCubit>();
    _date = widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _cubit.loadDate(_date);
  }

  @override
  void dispose() {
    _cubit.close();
    _countedController.dispose();
    _openingController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${l10n.navHistory} — ${l10n.dailyCloseTitle}'),
        ),
        body: BlocConsumer<DailyCloseCubit, DailyCloseState>(
          listener: (context, state) {
            if (state.status == DailyCloseStatus.closed) {
              _openingController.text = state.openingCash.toStringAsFixed(2);
              _countedController.text = state.countedCash.toStringAsFixed(2);
              _noteController.text = state.note;
            }
            if (state.status == DailyCloseStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == DailyCloseStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final isReadOnly = state.isClosed;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date Selector
                _DateCard(date: _date, isReadOnly: isReadOnly),
                const SizedBox(height: 16),

                // Summary (shown after close, or preview before)
                if (state.dailyClose != null) ...[
                  _SummaryCard(dailyClose: state.dailyClose!),
                  const SizedBox(height: 16),
                ],

                // Cash Reconciliation
                _ReconciliationCard(
                  openingController: _openingController,
                  countedController: _countedController,
                  noteController: _noteController,
                  openingCash: state.openingCash,
                  expectedCash: state.dailyClose?.expectedCash ?? 0,
                  countedCash: state.countedCash,
                  overShort: state.overShort,
                  isReadOnly: isReadOnly,
                  onOpeningChanged: (v) {
                    final val = double.tryParse(v) ?? 0;
                    _cubit.setOpeningCash(val);
                  },
                  onCountedChanged: (v) {
                    final val = double.tryParse(v) ?? 0;
                    _cubit.setCountedCash(val);
                  },
                  onNoteChanged: (v) {
                    _cubit.setNote(v);
                  },
                ),
                const SizedBox(height: 24),

                // Actions
                if (!isReadOnly)
                  FilledButton.icon(
                    onPressed: state.status == DailyCloseStatus.closing
                        ? null
                        : () => _confirmClose(context),
                    icon: const Icon(Icons.lock_outline),
                    label: Text(l10n.closeDay),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: state.status == DailyCloseStatus.reopening
                        ? null
                        : () => _confirmReopen(context),
                    icon: const Icon(Icons.lock_open_outlined),
                    label: Text(l10n.reopenDay),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmClose(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.closeDayConfirmTitle),
        content: Text(ctx.l10n.closeDayConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.closeDay(deviceId: '');
            },
            child: Text(ctx.l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _confirmReopen(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.reopenDayConfirmTitle),
        content: Text(ctx.l10n.reopenDayConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.reopenDay();
            },
            child: Text(ctx.l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.date, required this.isReadOnly});
  final String date;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(formatted),
        subtitle: Text(isReadOnly ? 'Closed' : 'Open'),
        trailing: isReadOnly
            ? Chip(
                label: Text('CLOSED', style: TextStyle(color: cs.onPrimary)),
                backgroundColor: cs.primary,
              )
            : Chip(
                label: Text(
                  'OPEN',
                  style: TextStyle(color: cs.onErrorContainer),
                ),
                backgroundColor: cs.errorContainer,
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.dailyClose});
  final DailyClose dailyClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _SummaryRow(
              label: 'Sales count',
              value: Text('${dailyClose.salesCount}'),
            ),
            _SummaryRow(
              label: 'Voided count',
              value: Text('${dailyClose.voidCount}'),
            ),
            const Divider(),
            _SummaryRow(
              label: 'Gross revenue',
              value: MoneyText(
                value: dailyClose.totalRevenue + dailyClose.totalVoid,
                currency: '฿',
              ),
            ),
            _SummaryRow(
              label: 'Voided amount',
              value: MoneyText(
                value: -dailyClose.totalVoid,
                currency: '฿',
                color: Colors.red,
              ),
            ),
            const Divider(),
            _SummaryRow(
              label: 'Net revenue',
              value: MoneyText(
                value: dailyClose.totalRevenue,
                currency: '฿',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (dailyClose.paymentBreakdown.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('By payment:', style: Theme.of(context).textTheme.bodySmall),
              ...dailyClose.paymentBreakdown.entries.map(
                (e) => _SummaryRow(
                  label: '  ${e.key}',
                  value: MoneyText(value: e.value, currency: '฿'),
                ),
              ),
            ],
            if (dailyClose.vatAmount > 0)
              _SummaryRow(
                label: 'VAT collected',
                value: MoneyText(value: dailyClose.vatAmount, currency: '฿'),
              ),
            if (dailyClose.discountAmount > 0)
              _SummaryRow(
                label: 'Discounts given',
                value: MoneyText(
                  value: -dailyClose.discountAmount,
                  currency: '฿',
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), value],
      ),
    );
  }
}

class _ReconciliationCard extends StatelessWidget {
  const _ReconciliationCard({
    required this.openingController,
    required this.countedController,
    required this.noteController,
    required this.openingCash,
    required this.expectedCash,
    required this.countedCash,
    required this.overShort,
    required this.isReadOnly,
    required this.onOpeningChanged,
    required this.onCountedChanged,
    required this.onNoteChanged,
  });

  final TextEditingController openingController;
  final TextEditingController countedController;
  final TextEditingController noteController;
  final double openingCash;
  final double expectedCash;
  final double countedCash;
  final double overShort;
  final bool isReadOnly;
  final ValueChanged<String> onOpeningChanged;
  final ValueChanged<String> onCountedChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  Widget build(BuildContext context) {
    final overShortColor = overShort > 0
        ? Colors.green
        : overShort < 0
        ? Colors.red
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Reconciliation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            TextField(
              controller: openingController,
              readOnly: isReadOnly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Opening cash',
                prefixText: '฿',
              ),
              onChanged: onOpeningChanged,
            ),
            const SizedBox(height: 8),
            _ReadOnlyRow(
              label: 'Expected cash',
              value: MoneyText(value: expectedCash, currency: '฿'),
            ),
            TextField(
              controller: countedController,
              readOnly: isReadOnly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Counted cash',
                prefixText: '฿',
              ),
              onChanged: onCountedChanged,
            ),
            const SizedBox(height: 8),
            _ReadOnlyRow(
              label: 'Over / Short',
              value: Text(
                '${overShort >= 0 ? '+' : ''}${MoneyUtils.round(overShort).toStringAsFixed(2)}',
                style: TextStyle(
                  color: overShortColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              readOnly: isReadOnly,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              onChanged: onNoteChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          value,
        ],
      ),
    );
  }
}
