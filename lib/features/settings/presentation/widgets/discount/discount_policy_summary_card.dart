import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class DiscountPolicySummaryCard extends StatelessWidget {
  const DiscountPolicySummaryCard({
    required this.enableItemDiscount,
    required this.enableCartDiscount,
    required this.defaultDiscountType,
    required this.maxDiscountPercent,
    required this.maxDiscountAmount,
    required this.currency,
    super.key,
  });

  final bool enableItemDiscount;
  final bool enableCartDiscount;
  final String defaultDiscountType;
  final double maxDiscountPercent;
  final double maxDiscountAmount;
  final String currency;

  String _typeLabel(BuildContext context) {
    return defaultDiscountType == 'PERCENT'
        ? context.l10n.discountTypePercent
        : context.l10n.discountTypeAmount;
  }

  String _percentLabel(BuildContext context) {
    return '${maxDiscountPercent.toStringAsFixed(0)}%';
  }

  String _amountLabel(BuildContext context) {
    if (maxDiscountAmount <= 0) {
      return context.l10n.maxAmountNoLimit;
    }
    return '$currency${maxDiscountAmount.toStringAsFixed(0)}';
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
            child: Icon(
              Icons.local_offer_outlined,
              color: st.softAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.settingsDiscountPolicy,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: enableItemDiscount
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            label: context.l10n.enableItemDiscount,
            value: enableItemDiscount ? 'ON' : 'OFF',
            st: st,
          ),
          _buildRow(
            icon: enableCartDiscount
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            label: context.l10n.enableCartDiscount,
            value: enableCartDiscount ? 'ON' : 'OFF',
            st: st,
          ),
          _buildRow(
            icon: Icons.settings_outlined,
            label: context.l10n.defaultDiscountType,
            value: _typeLabel(context),
            st: st,
          ),
          _buildRow(
            icon: Icons.percent_outlined,
            label: context.l10n.maxDiscountPercent,
            value: _percentLabel(context),
            st: st,
          ),
          _buildRow(
            icon: Icons.trending_down_outlined,
            label: context.l10n.maxDiscountAmount,
            value: _amountLabel(context),
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
