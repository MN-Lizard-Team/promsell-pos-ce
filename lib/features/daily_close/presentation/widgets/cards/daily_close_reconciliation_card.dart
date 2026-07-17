import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/rows/daily_close_read_only_row.dart';
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
    final overShortColor = overShort > 0
        ? AppColors.success
        : overShort < 0
        ? AppColors.error
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyCloseCashReconciliation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            TextField(
              controller: openingController,
              readOnly: isReadOnly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.dailyCloseOpeningCash,
                prefixText: currency,
              ),
              onChanged: onOpeningChanged,
            ),
            const SizedBox(height: 8),
            DailyCloseReadOnlyRow(
              label: l10n.dailyCloseExpectedCash,
              value: MoneyText(value: expectedCash, currency: currency),
            ),
            TextField(
              controller: countedController,
              readOnly: isReadOnly,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.dailyCloseCountedCash,
                prefixText: currency,
              ),
              onChanged: onCountedChanged,
            ),
            const SizedBox(height: 8),
            DailyCloseReadOnlyRow(
              label: l10n.dailyCloseOverShort,
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
              decoration: InputDecoration(
                labelText: l10n.dailyCloseNoteOptional,
              ),
              onChanged: onNoteChanged,
            ),
          ],
        ),
      ),
    );
  }

  String _currency(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.settings.currency;
    } catch (_) {
      return '฿';
    }
  }
}
