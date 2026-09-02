import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/cubit/daily_close_cubit.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_date_card.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_reconciliation_card.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_summary_card.dart';

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
        appBar: AppBar(title: Text(l10n.dailyCloseTitle)),
        body: BlocConsumer<DailyCloseCubit, DailyCloseState>(
          listener: (context, state) {
            if (state.status == DailyCloseStatus.closed ||
                state.status == DailyCloseStatus.reopened) {
              _syncControllers(state);
              if (state.status == DailyCloseStatus.closed) {
                AppSnackBar.success(context, l10n.dailyCloseStatusClosed);
              }
            }
            if (state.status == DailyCloseStatus.error &&
                state.errorMessage != null) {
              AppSnackBar.error(context, l10n.errorOccurred);
            }
          },
          builder: (context, state) {
            if (state.status == DailyCloseStatus.loading ||
                state.status == DailyCloseStatus.calculating) {
              return _ProgressState(
                message: state.status == DailyCloseStatus.calculating
                    ? l10n.dailyCloseCalculating
                    : l10n.loading,
              );
            }
            if (state.status == DailyCloseStatus.error) {
              return AppEmptyState(
                icon: Icons.cloud_off_outlined,
                title: l10n.errorOccurred,
                message: l10n.dailyCloseLoadError(''),
                actionLabel: l10n.retry,
                onAction: () => _cubit.loadDate(_date),
              );
            }

            final isReadOnly = state.isClosed;
            final summary = _summaryFor(state);
            final busy =
                state.status == DailyCloseStatus.closing ||
                state.status == DailyCloseStatus.reopening;
            final body = ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: DailyCloseDateCard(
                    date: _date,
                    isReadOnly: isReadOnly,
                  ),
                ),
                const SizedBox(height: 12),
                if (summary != null) ...[
                  DailyCloseSummaryCard(dailyClose: summary),
                  const SizedBox(height: 12),
                ],
                DailyCloseReconciliationCard(
                  openingController: _openingController,
                  countedController: _countedController,
                  noteController: _noteController,
                  openingCash: state.openingCash,
                  expectedCash: state.expectedCash,
                  countedCash: state.countedCash,
                  overShort: state.overShort,
                  isReadOnly: isReadOnly,
                  onOpeningChanged: _onOpeningChanged,
                  onCountedChanged: _onCountedChanged,
                  onNoteChanged: _cubit.setNote,
                ),
                if (busy) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    semanticsLabel: state.status == DailyCloseStatus.closing
                        ? l10n.dailyCloseClosing
                        : l10n.dailyCloseReopening,
                  ),
                ],
              ],
            );

            return body;
          },
        ),
        bottomNavigationBar: BlocBuilder<DailyCloseCubit, DailyCloseState>(
          builder: (context, state) {
            if (state.status == DailyCloseStatus.loading ||
                state.status == DailyCloseStatus.calculating ||
                state.status == DailyCloseStatus.error) {
              return const SizedBox.shrink();
            }
            final isReadOnly = state.isClosed;
            final busy =
                state.status == DailyCloseStatus.closing ||
                state.status == DailyCloseStatus.reopening;
            return StickyActionBar(
              primaryLabel: isReadOnly ? l10n.reopenDay : l10n.closeDay,
              primaryKey: Key(
                isReadOnly ? TestKeys.reopenDayButton : TestKeys.closeDayButton,
              ),
              onPrimary: busy
                  ? null
                  : () => isReadOnly
                        ? _confirmReopen(context)
                        : _confirmClose(context),
              isLoading: busy,
              primaryColor: isReadOnly
                  ? Theme.of(context).colorScheme.error
                  : null,
            );
          },
        ),
      ),
    );
  }

  DailyClose? _summaryFor(DailyCloseState state) {
    if (state.dailyClose != null && state.isClosed) return state.dailyClose;
    final preview = state.preview;
    if (preview == null) return null;
    return DailyClose(
      id: 'preview',
      closeDate: _date,
      openingCash: Money.zero,
      totalRevenue: preview.netRevenue,
      totalVoid: preview.voidedTotal,
      salesCount: preview.salesCount,
      voidCount: preview.voidCount,
      paymentBreakdown: preview.paymentBreakdown,
      vatAmount: preview.vatAmount,
      discountAmount: preview.discountAmount,
    );
  }

  void _syncControllers(DailyCloseState state) {
    _openingController.text = state.openingCash.toStringAsFixed(2);
    _countedController.text = state.countedCash.toStringAsFixed(2);
    _noteController.text = state.note;
  }

  void _onOpeningChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed.isFinite && parsed >= 0) {
      _cubit.setOpeningCash(parsed);
    }
  }

  void _onCountedChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed.isFinite && parsed >= 0) {
      _cubit.setCountedCash(parsed);
    }
  }

  Future<void> _confirmClose(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirm(
      context,
      title: l10n.closeDayConfirmTitle,
      message: l10n.closeDayConfirmMessage,
      confirmLabel: l10n.closeDay,
      cancelLabel: l10n.cancel,
      icon: Icons.lock_outline,
    );
    if (!confirmed || !context.mounted) return;
    final unlocked = await ensureAppUnlocked(
      context,
      title: l10n.closeDayConfirmTitle,
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
      confirmLabel: l10n.reopenDay,
      cancelLabel: l10n.cancel,
      destructive: true,
      icon: Icons.lock_open_outlined,
    );
    if (!confirmed || !context.mounted) return;
    final unlocked = await ensureAppUnlocked(
      context,
      title: l10n.reopenDayConfirmTitle,
    );
    if (!unlocked || !context.mounted) return;
    await _cubit.reopenDay();
  }
}

class _ProgressState extends StatelessWidget {
  const _ProgressState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}
