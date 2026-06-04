import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class ReceiptSummaryCard extends StatelessWidget {
  const ReceiptSummaryCard({
    required this.receiptNote,
    required this.showShopInfo,
    required this.previewStyle,
    required this.vatMode,
    required this.vatRate,
    super.key,
  });

  final String receiptNote;
  final bool showShopInfo;
  final String previewStyle;
  final String vatMode;
  final double vatRate;

  IconData get _styleIcon {
    return switch (previewStyle) {
      'thermal' => Icons.receipt_long_outlined,
      'card' => Icons.credit_card_outlined,
      _ => Icons.visibility_off_outlined,
    };
  }

  String _styleLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (previewStyle) {
      'thermal' => l10n.receiptPreviewStyleThermal,
      'card' => l10n.receiptPreviewStyleCard,
      _ => l10n.receiptPreviewStyleNone,
    };
  }

  String _vatLabel(BuildContext context) {
    final l10n = context.l10n;
    if (vatMode == 'NONE') return l10n.vatModeNone;
    final mode = vatMode == 'INCLUSIVE'
        ? l10n.vatModeInclusive
        : l10n.vatModeExclusive;
    return '$mode @ ${vatRate.toStringAsFixed(1)}%';
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
            child: Icon(_styleIcon, color: st.softAccent, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.settingsReceipt,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (receiptNote.isNotEmpty)
            _buildRow(
              icon: Icons.notes_outlined,
              label: context.l10n.settingsReceiptNote,
              value: receiptNote,
              st: st,
            ),
          _buildRow(
            icon: showShopInfo
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            label: context.l10n.settingsShowShopInfo,
            value: showShopInfo ? 'ON' : 'OFF',
            st: st,
          ),
          _buildRow(
            icon: _styleIcon,
            label: context.l10n.settingsReceiptPreviewStyle,
            value: _styleLabel(context),
            st: st,
          ),
          _buildRow(
            icon: Icons.percent_outlined,
            label: context.l10n.settingsVatMode,
            value: _vatLabel(context),
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
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: st.softTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
