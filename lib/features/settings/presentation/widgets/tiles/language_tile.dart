import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/responsive_settings_picker.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    super.key,
    required this.current,
    required this.onChanged,
  });
  final Locale current;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ResponsiveSettingsPicker(
      icon: Icons.language,
      title: l10n.settingsLanguage,
      child: DropdownButton<String>(
        value: current.languageCode,
        isExpanded: true,
        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        iconEnabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: [
          DropdownMenuItem(value: 'th', child: Text(l10n.langThai)),
          DropdownMenuItem(value: 'en', child: Text(l10n.langEnglish)),
        ],
        onChanged: (code) {
          if (code != null) {
            HapticFeedback.selectionClick();
            onChanged(Locale(code));
          }
        },
      ),
    );
  }
}
