import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/rows/daily_close_read_only_row.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class DailyCloseReconciliationCard extends StatelessWidget {
  const DailyCloseReconciliationCard({
    super.key,
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
    final l10n = context.l10n;
    final currency = _currency(context);
    final scheme = Theme.of(context).colorScheme;
    final direction = overShort > 0
        ? l10n.dailyCloseOverAmount(_amountLabel(currency, overShort.abs()))
        : overShort < 0
        ? l10n.dailyCloseShortAmount(_amountLabel(currency, overShort.abs()))
        : l10n.dailyCloseNoMismatch;
    final statusColor = overShort > 0
        ? scheme.tertiary
        : overShort < 0
        ? scheme.error
        : scheme.primary;

    return ReportSectionCard(
      title: l10n.dailyCloseCashReconciliation,
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key(TestKeys.openingCashField),
            controller: openingController,
            readOnly: isReadOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.dailyCloseOpeningCash,
              prefixText: currency,
            ),
            onChanged: onOpeningChanged,
          ),
          const SizedBox(height: 10),
          DailyCloseReadOnlyRow(
            label: l10n.dailyCloseExpectedCash,
            value: MoneyText(
              key: const Key(TestKeys.expectedCashValue),
              value: expectedCash,
              currency: currency,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key(TestKeys.countedCashField),
            controller: countedController,
            readOnly: isReadOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.dailyCloseCountedCash,
              prefixText: currency,
            ),
            onChanged: onCountedChanged,
          ),
          const SizedBox(height: 12),
          Semantics(
            container: true,
            label: '${l10n.dailyCloseOverShort}: $direction',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.28)),
              ),
              child: Row(
                children: [
                  Icon(
                    overShort > 0
                        ? Icons.trending_up
                        : overShort < 0
                        ? Icons.trending_down
                        : Icons.check_circle_outline,
                    color: statusColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dailyCloseOverShort,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          direction,
                          key: const Key(TestKeys.overShortValue),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            readOnly: isReadOnly,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.dailyCloseNoteOptional),
            onChanged: onNoteChanged,
          ),
        ],
      ),
    );
  }

  String _amountLabel(String currency, double amount) =>
      '$currency${amount.toStringAsFixed(2)}';

  String _currency(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.settings.currency;
    } catch (_) {
      return '฿';
    }
  }
}
