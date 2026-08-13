import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class UsageNote extends StatelessWidget {
  const UsageNote({
    super.key,
    required this.l10n,
    required this.scheme,
    required this.reportTheme,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ReportThemeExtension reportTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(reportTheme.controlRadius),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(TablerIcons.infoCircle, size: 19, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.dateFilterTipBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
