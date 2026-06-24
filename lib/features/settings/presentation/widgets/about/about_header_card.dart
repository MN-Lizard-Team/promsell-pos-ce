import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/version_chip.dart';

class AboutHeaderCard extends StatelessWidget {
  const AboutHeaderCard({
    super.key,
    required this.version,
    required this.buildNumber,
    required this.st,
  });

  final String version;
  final String buildNumber;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            st.softAccent.withValues(alpha: 0.35),
            st.softAccent.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(
          color: st.softAccent.withValues(alpha: 0.50),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: st.iconContainerBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.point_of_sale, color: st.softAccent, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Promsell POS CE',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.appDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: st.softTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VersionChip(label: l10n.appVersion, value: version, st: st),
              const SizedBox(width: 12),
              VersionChip(label: l10n.appBuild, value: buildNumber, st: st),
            ],
          ),
        ],
      ),
    );
  }
}
