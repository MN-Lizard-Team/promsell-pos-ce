import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_summary_card.dart';

class ReceiptSettingsPage extends StatelessWidget {
  const ReceiptSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();

        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settingsReceipt)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              ReceiptSummaryCard(
                receiptNote: s.receiptNote,
                showShopInfo: s.showShopInfoOnReceipt,
                previewStyle: s.receiptPreviewStyle,
                vatMode: s.vatMode,
                vatRate: s.vatRate,
              ),
              const SizedBox(height: 24),
              ReceiptSettingsForm(
                settings: s,
                onUpdate: (next) => cubit.updateField((_) => next),
              ),
            ],
          ),
        );
      },
    );
  }
}
