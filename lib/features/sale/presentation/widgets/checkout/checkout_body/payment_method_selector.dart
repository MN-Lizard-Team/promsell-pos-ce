import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.method,
    required this.promptpayEnabled,
    required this.onChanged,
  });

  final String method;
  final bool promptpayEnabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PaymentMethodCard(
            icon: Icons.payments_outlined,
            label: context.l10n.cash,
            selected: method == 'cash',
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged('cash');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PaymentMethodCard(
            icon: Icons.qr_code_2_outlined,
            label: context.l10n.transfer,
            selected: method == 'transfer',
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged('transfer');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PaymentMethodCard(
            icon: Icons.credit_card,
            label: context.l10n.card,
            selected: method == 'card',
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged('card');
            },
          ),
        ),
        if (promptpayEnabled) ...[
          const SizedBox(width: 8),
          Expanded(
            child: PaymentMethodCard(
              icon: Icons.account_balance_wallet_outlined,
              label: context.l10n.promptpay,
              selected: method == 'promptpay',
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged('promptpay');
              },
            ),
          ),
        ],
      ],
    );
  }
}
