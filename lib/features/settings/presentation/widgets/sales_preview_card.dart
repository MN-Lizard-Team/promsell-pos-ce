import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SalesPreviewCard extends StatelessWidget {
  const SalesPreviewCard({
    required this.currency,
    required this.dateFormat,
    required this.maxDrafts,
    required this.cartCompactMode,
    required this.ultraCompactMode,
    super.key,
  });

  final String currency;
  final String dateFormat;
  final int maxDrafts;
  final bool cartCompactMode;
  final bool ultraCompactMode;

  IconData get _modeIcon {
    if (ultraCompactMode) return Icons.density_small;
    if (cartCompactMode) return Icons.view_compact_outlined;
    return Icons.shopping_cart_outlined;
  }

  String _modeLabel(BuildContext context) {
    if (ultraCompactMode) return 'Ultra Compact';
    if (cartCompactMode) return 'Compact';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;

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
            child: Icon(_modeIcon, color: st.softAccent, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            '${context.l10n.settingsSales} Preview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: Icons.attach_money_outlined,
            label: context.l10n.settingsCurrency,
            value: currency,
            st: st,
          ),
          _buildRow(
            icon: Icons.calendar_today_outlined,
            label: context.l10n.settingsDateFormat,
            value: dateFormat,
            st: st,
          ),
          _buildRow(
            icon: Icons.folder_copy_outlined,
            label: context.l10n.settingsMaxDrafts,
            value: maxDrafts.toString(),
            st: st,
          ),
          _buildRow(
            icon: _modeIcon,
            label: 'Mode',
            value: _modeLabel(context),
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
