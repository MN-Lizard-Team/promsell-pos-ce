import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/cubit/daily_close_cubit.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_date_card.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_reconciliation_card.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_summary_card.dart';
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
              AppSnackBar.error(
                context,
                state.errorMessage ?? context.l10n.errorOccurred,
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
                DailyCloseDateCard(date: _date, isReadOnly: isReadOnly),
                const SizedBox(height: 16),

                // Summary (shown after close, or preview before)
                if (state.dailyClose != null) ...[
                  DailyCloseSummaryCard(dailyClose: state.dailyClose!),
                  const SizedBox(height: 16),
                ],

                // Cash Reconciliation
                DailyCloseReconciliationCard(
                  openingController: _openingController,
                  countedController: _countedController,
                  noteController: _noteController,
                  openingCash: state.openingCash,
                  expectedCash: state.dailyClose?.expectedCash.value ?? 0,
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
                    key: const Key(TestKeys.closeDayButton),
                    onPressed: state.status == DailyCloseStatus.closing
                        ? null
                        : () => _confirmClose(context),
                    icon: const Icon(Icons.lock_outline),
                    label: Text(l10n.closeDay),
                  )
                else
                  OutlinedButton.icon(
                    key: const Key(TestKeys.reopenDayButton),
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

  Future<void> _confirmClose(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirm(
      context,
      title: l10n.closeDayConfirmTitle,
      message: l10n.closeDayConfirmMessage,
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
      destructive: false,
      icon: Icons.lock_outline,
    );
    if (!confirmed || !context.mounted) return;
    // V092-B.3: prompt store PIN before closing the day.
    final unlocked = await ensureAppUnlocked(
      context,
      title: context.l10n.appLockConfirmStock,
    );
    if (!unlocked || !context.mounted) return;
    await _cubit.closeDay(deviceId: '');
  }

  Future<void> _confirmReopen(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirm(
      context,
      title: l10n.reopenDayConfirmTitle,
      message: l10n.reopenDayConfirmMessage,
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
      destructive: false,
      icon: Icons.lock_open_outlined,
    );
    if (!confirmed || !context.mounted) return;
    // V092-B.3: prompt store PIN before reopening the day.
    final unlocked = await ensureAppUnlocked(
      context,
      title: context.l10n.appLockConfirmStock,
    );
    if (!unlocked || !context.mounted) return;
    await _cubit.reopenDay();
  }
}
