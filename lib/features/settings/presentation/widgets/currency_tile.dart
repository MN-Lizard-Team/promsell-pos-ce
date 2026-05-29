import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/responsive_settings_picker.dart';

class CurrencyTile extends StatelessWidget {
  const CurrencyTile({
    super.key,
    required this.current,
    required this.onChanged,
  });
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSettingsPicker(
      icon: Icons.attach_money,
      title: context.l10n.settingsCurrency,
      child: DropdownButton<String>(
        value: current,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: '฿', child: Text('฿ (THB)')),
          DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
          DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
