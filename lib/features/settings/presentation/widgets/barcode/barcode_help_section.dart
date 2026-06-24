import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class BarcodeHelpSection extends StatelessWidget {
  const BarcodeHelpSection({super.key, required this.st});

  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      leading: Icon(Icons.help_outline, color: st.softAccent),
      title: Text(
        l10n.barcodeHelpTitle,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        _helpItem(
          icon: Icons.info_outline,
          title: l10n.barcodeHelpWhatIsTitle,
          body: l10n.barcodeHelpWhatIsBody,
        ),
        _helpItem(
          icon: Icons.camera_alt_outlined,
          title: l10n.barcodeHelpHowToScanTitle,
          body: l10n.barcodeHelpHowToScanBody,
        ),
        _helpItem(
          icon: Icons.auto_fix_high_outlined,
          title: l10n.barcodeHelpNoBarcodeTitle,
          body: l10n.barcodeHelpNoBarcodeBody,
        ),
      ],
    );
  }

  Widget _helpItem({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: st.softAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: st.softTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: st.softTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
