import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment/payment_widgets.dart';

class OrderTypeSelector extends StatelessWidget {
  const OrderTypeSelector({
    required this.orderType,
    required this.onChanged,
    super.key,
  });

  final String orderType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final types = [
      ('dinein', l10n.orderTypeDineIn, Icons.dining_outlined),
      ('takeaway', l10n.orderTypeTakeaway, Icons.takeout_dining_outlined),
      ('delivery', l10n.orderTypeDelivery, Icons.delivery_dining_outlined),
    ];

    return Row(
      children: types.expand((t) {
        final (value, label, icon) = t;
        return [
          Expanded(
            child: PaymentMethodCard(
              icon: icon,
              label: label,
              selected: orderType == value,
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
