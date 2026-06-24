import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/dialog_option_tile.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class GeneralLanguageTile extends StatelessWidget {
  const GeneralLanguageTile({
    super.key,
    required this.settings,
    required this.onUpdate,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final s = settings;

    final label = s.locale.languageCode == 'th'
        ? l10n.langThai
        : l10n.langEnglish;

    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.language_outlined, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.settingsLanguage,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: st.softAccent,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 20),
        ],
      ),
      onTap: () => _showLanguageDialog(context, s, st, l10n),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final options = const [Locale('th'), Locale('en')];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((locale) {
            final isSelected = locale == s.locale;
            final label = locale.languageCode == 'th'
                ? l10n.langThai
                : l10n.langEnglish;
            return DialogOptionTile(
              icon: Icons.language,
              label: label,
              isSelected: isSelected,
              st: st,
              onTap: () {
                HapticFeedback.lightImpact();
                onUpdate(s.copyWith(locale: locale));
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
