import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class BarcodePreviewCard extends StatelessWidget {
  const BarcodePreviewCard({
    super.key,
    required this.scanEnabled,
    required this.prefix,
    required this.vibrateOnScan,
  });

  final bool scanEnabled;
  final String prefix;
  final bool vibrateOnScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: st.iconContainerBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              scanEnabled
                  ? Icons.qr_code_scanner_outlined
                  : Icons.qr_code_outlined,
              color: st.softAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.barcodeSettings,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: scanEnabled
                ? Icons.check_circle_outline
                : Icons.block_outlined,
            label: l10n.enableBarcodeScan,
            value: scanEnabled
                ? l10n.settingsStatusActive
                : l10n.settingsStatusNotSet,
            st: st,
          ),
          _buildRow(
            icon: Icons.text_fields_outlined,
            label: l10n.barcodePrefix,
            value: prefix,
            st: st,
          ),
          _buildRow(
            icon: vibrateOnScan
                ? Icons.vibration
                : Icons.do_not_disturb_on_outlined,
            label: l10n.playBeepOnScan,
            value: vibrateOnScan
                ? l10n.settingsStatusActive
                : l10n.settingsStatusNotSet,
            st: st,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required SettingsThemeExtension st,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: st.softAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: st.softTextSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: st.softTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
