import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/promptpay_qr_code.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class PromptpayPreviewCard extends StatelessWidget {
  const PromptpayPreviewCard({
    super.key,
    required this.promptpayId,
    required this.st,
    required this.l10n,
    this.overlayIcon,
  });

  final String promptpayId;
  final SettingsThemeExtension st;
  final AppLocalizations l10n;
  final String? overlayIcon;

  @override
  Widget build(BuildContext context) {
    final hasId = promptpayId.isNotEmpty;
    final accentColor = hasId ? AppColors.success : st.mutedText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.2),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasId)
            PromptPayQrCode(
              promptpayId: promptpayId,
              amount: 100.0,
              size: 160,
              overlayIcon: overlayIcon,
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.qr_code_scanner_outlined,
                color: accentColor,
                size: 28,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            hasId ? l10n.promptpayQrPreview : l10n.promptpayNotConfigured,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (hasId)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: st.softTextSecondary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  promptpayId,
                  style: TextStyle(fontSize: 14, color: st.softTextSecondary),
                ),
              ],
            )
          else
            Text(
              l10n.settingsPromptpayIdHint,
              style: TextStyle(fontSize: 14, color: st.softTextSecondary),
            ),
        ],
      ),
    );
  }
}
