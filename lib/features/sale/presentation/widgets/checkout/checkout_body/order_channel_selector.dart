import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

class OrderChannelSelector extends StatelessWidget {
  const OrderChannelSelector({
    required this.orderChannel,
    required this.onChanged,
    super.key,
  });

  final String orderChannel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final channels = [
      ('walkin', l10n.orderChannelWalkIn, Icons.store_outlined),
      ('phone', l10n.orderChannelPhone, Icons.phone_outlined),
      ('online', l10n.orderChannelOnline, Icons.language_outlined),
    ];

    return Row(
      children: channels.expand((c) {
        final (value, label, icon) = c;
        return [
          Expanded(
            child: PaymentMethodCard(
              icon: icon,
              label: label,
              selected: orderChannel == value,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(value);
              },
            ),
          ),
          const SizedBox(width: 8),
        ];
      }).toList()..removeLast(),
    );
  }
}
