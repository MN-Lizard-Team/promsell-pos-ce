import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/cart_summary_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/payment_action_chip.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/payment_status_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/qr_display_section.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/reference_input_field.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:thai_promptpay/thai_promptpay.dart' as pp;

class PromptPayLayout extends StatelessWidget {
  const PromptPayLayout({
    super.key,
    required this.l10n,
    required this.theme,
    required this.items,
    required this.total,
    required this.currency,
    required this.promptpayId,
    required this.settings,
    required this.cartExpanded,
    required this.onToggleExpand,
    required this.sendingBankCode,
    required this.referenceController,
    required this.onReferenceChanged,
    required this.onShare,
    required this.onScanSlip,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final List<CartItem> items;
  final double total;
  final String currency;
  final String promptpayId;
  final Settings settings;
  final bool cartExpanded;
  final VoidCallback onToggleExpand;
  final String? sendingBankCode;
  final TextEditingController referenceController;
  final ValueChanged<String> onReferenceChanged;
  final VoidCallback onShare;
  final VoidCallback onScanSlip;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCartSummary(),
                      const SizedBox(height: 20),
                      _buildStatusCard(),
                      const SizedBox(height: 20),
                      _buildReferenceInput(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildQrSection(),
                      const SizedBox(height: 20),
                      _buildActionsRow(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCartSummary(),
              const SizedBox(height: 20),
              _buildQrSection(),
              const SizedBox(height: 20),
              _buildActionsRow(),
              const SizedBox(height: 20),
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildReferenceInput(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartSummary() {
    return CartSummaryCard(
      items: items,
      total: total,
      currency: currency,
      isExpanded: cartExpanded,
      onToggleExpand: onToggleExpand,
      cartLabel: l10n.cart,
      totalLabel: l10n.total,
      showMoreLabel: l10n.showMore,
      showLessLabel: l10n.showLess,
    );
  }

  Widget _buildQrSection() {
    return QrDisplaySection(
      promptpayId: promptpayId,
      amount: total,
      currency: currency,
      overlayIcon: settings.qrOverlayIcon,
      onShare: onShare,
      copyLabel: l10n.copyPromptpayId,
      l10n: l10n,
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        PaymentActionChip(
          icon: Icons.share,
          label: l10n.promptpayShareQr,
          onTap: onShare,
        ),
        PaymentActionChip(
          icon: Icons.document_scanner,
          label: l10n.slipScanTitle,
          onTap: onScanSlip,
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final hasBank = sendingBankCode != null && sendingBankCode!.isNotEmpty;
    final bankName = hasBank
        ? (pp.thaiBankByCode(sendingBankCode!)?.nameTh ?? sendingBankCode!)
        : null;
    return PaymentStatusCard(
      sendingBankCode: sendingBankCode,
      bankName: bankName,
      verifiedLabel: l10n.paymentVerified,
      waitingLabel: l10n.waitingForPayment,
    );
  }

  Widget _buildReferenceInput() {
    return ReferenceInputField(
      controller: referenceController,
      label: l10n.promptpayTransactionReference,
      onChanged: onReferenceChanged,
    );
  }
}
