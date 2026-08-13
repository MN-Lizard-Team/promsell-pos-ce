import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

/// Payment method picker — 2×2 grid (PromptPay optional 4th cell).
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

  void _select(String value) {
    HapticFeedback.selectionClick();
    onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final methods = <({String id, IconData icon, String label})>[
      (id: 'cash', icon: Icons.payments_outlined, label: l.cash),
      (id: 'transfer', icon: Icons.account_balance_outlined, label: l.transfer),
      (id: 'card', icon: Icons.credit_card, label: l.card),
      if (promptpayEnabled)
        (
          id: 'promptpay',
          icon: Icons.account_balance_wallet_outlined,
          label: l.promptpay,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns; height grows with label wrap.
        const gap = 8.0;
        final cellW = (constraints.maxWidth - gap) / 2;
        return Wrap(
          key: const ValueKey('sale_payment_method_grid'),
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final m in methods)
              SizedBox(
                width: cellW,
                child: PaymentMethodCard(
                  icon: m.icon,
                  label: m.label,
                  selected: method == m.id,
                  onTap: () => _select(m.id),
                ),
              ),
          ],
        );
      },
    );
  }
}
