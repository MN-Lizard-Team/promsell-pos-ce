import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class AboutLinkTile extends StatelessWidget {
  const AboutLinkTile({
    super.key,
    required this.icon,
    required this.label,
    required this.st,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final SettingsThemeExtension st;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: st.softAccent, size: 24),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: onTap,
    );
  }
}
