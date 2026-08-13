import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_summary_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';

class ReceiptSettingsPage extends StatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  State<ReceiptSettingsPage> createState() => _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends State<ReceiptSettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.settings != curr.settings,
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l = context.l10n;

        // Build mock receipt preview data from current settings.
        final previewStyle = switch (s.receiptPreviewStyle) {
          'card' => ReceiptPreviewStyle.card,
          'none' => ReceiptPreviewStyle.none,
          _ => ReceiptPreviewStyle.thermal,
        };
        final mockItems = [
          const ReceiptPreviewItem(
            name: 'Latte',
            qty: 2,
            price: 60,
            subtotal: 120,
          ),
          const ReceiptPreviewItem(
            name: 'Croissant',
            qty: 1,
            price: 45,
            subtotal: 45,
          ),
        ];
        final mockVat = s.vatMode.toUpperCase() != 'NONE'
            ? (
                subtotal: 165.0,
                vatAmount: 165.0 * s.vatRate / 100,
                totalWithVat: 165.0 * (1 + s.vatRate / 100),
                isInclusive: s.vatMode.toUpperCase() == 'INCLUSIVE',
              )
            : null;
        final mockLabels = ReceiptLabels(
          receipt: l.receiptLabelReceipt,
          payment: l.receiptLabelPayment,
          paymentMethodLabel: l.cash,
          total: l.receiptLabelTotal,
          received: l.receiptLabelReceived,
          change: l.receiptLabelChange,
          note: l.receiptLabelNote,
          vat: l.receiptLabelVat,
          vatIncluded: l.receiptLabelVatIncluded(s.vatRate),
          subtotal: l.receiptLabelSubtotal,
          itemDiscounts: l.receiptItemDiscounts,
          cartDiscount: l.receiptCartDiscount,
          serviceCharge: l.serviceCharge,
          notTaxInvoice: s.taxId.trim().isEmpty ? l.receiptNotTaxInvoice : null,
          taxId: l.receiptTaxId,
          taxInvoice: l.receiptTaxInvoice,
          thankYou: l.receiptThankYouDefault,
        );

        return SettingsLeafChrome(
          title: l.settingsReceipt,
          header: ReceiptSummaryCard(
            receiptNote: s.receiptNote,
            showShopInfo: s.showShopInfoOnReceipt,
            previewStyle: s.receiptPreviewStyle,
            vatMode: s.vatMode,
            vatRate: s.vatRate,
          ),
          children: [
            ReceiptSettingsForm(
              settings: s,
              onUpdate: (next) => cubit.updateField((_) => next),
            ),
            if (previewStyle != ReceiptPreviewStyle.none) ...[
              const SizedBox(height: 16),
              Text(
                l.receiptPreview,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Center(
                child: ReceiptPreview(
                  settings: s,
                  labels: mockLabels,
                  style: previewStyle,
                  items: mockItems,
                  total: mockVat?.totalWithVat ?? 165.0,
                  vatInfo: mockVat,
                  paymentMethod: l.cash,
                  receiptNumber: 'R-001',
                  footerOverride: s.receiptNote.isNotEmpty
                      ? s.receiptNote
                      : l.receiptThankYouDefault,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
