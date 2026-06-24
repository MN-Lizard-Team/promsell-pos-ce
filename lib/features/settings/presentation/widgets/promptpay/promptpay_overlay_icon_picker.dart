import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class PromptpayOverlayIconPicker extends StatelessWidget {
  const PromptpayOverlayIconPicker({
    super.key,
    required this.settings,
    required this.cubit,
  });

  final Settings settings;
  final SettingsCubit cubit;

  static const _icons = <(String, IconData)>[
    ('', Icons.block),
    ('wallet', Icons.account_balance_wallet_outlined),
    ('store', Icons.store_outlined),
    ('person', Icons.person_outline),
    ('payment', Icons.payment_outlined),
    ('credit_card', Icons.credit_card_outlined),
    ('shopping_bag', Icons.shopping_bag_outlined),
    ('local_atm', Icons.local_atm_outlined),
    ('qr_code', Icons.qr_code_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _icons.map((entry) {
        final (iconName, iconData) = entry;
        return _buildIconChip(context, iconName, iconData);
      }).toList(),
    );
  }

  Widget _buildIconChip(
    BuildContext context,
    String iconName,
    IconData iconData,
  ) {
    final isSelected = settings.qrOverlayIcon == iconName;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        cubit.updateField(
          (current) => current.copyWith(qrOverlayIcon: iconName),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Icon(
          iconData,
          size: 20,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
