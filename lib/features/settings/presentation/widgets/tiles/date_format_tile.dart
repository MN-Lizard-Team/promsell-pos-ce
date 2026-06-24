import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/responsive_settings_picker.dart';

class DateFormatTile extends StatelessWidget {
  const DateFormatTile({
    super.key,
    required this.current,
    required this.onChanged,
  });
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSettingsPicker(
      icon: Icons.calendar_today_outlined,
      title: context.l10n.settingsDateFormat,
      child: DropdownButton<String>(
        value: current,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
          DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
          DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
