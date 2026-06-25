import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/promptpay_qr_code.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class QrDisplaySection extends StatelessWidget {
  const QrDisplaySection({
    super.key,
    required this.promptpayId,
    required this.amount,
    required this.currency,
    required this.overlayIcon,
    required this.onShare,
    required this.copyLabel,
    required this.l10n,
  });

  final String promptpayId;
  final double amount;
  final String currency;
  final String overlayIcon;
  final VoidCallback onShare;
  final String copyLabel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showQrFullscreen(context, theme),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Semantics(
                label:
                    'PromptPay QR code, $currency${amount.toStringAsFixed(2)}',
                child: PromptPayQrCode(
                  promptpayId: promptpayId,
                  amount: amount,
                  size: 240,
                  overlayIcon: overlayIcon,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                promptpayId,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: promptpayId));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(copyLabel)));
                },
                icon: const Icon(Icons.copy, size: 18),
                tooltip: copyLabel,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQrFullscreen(BuildContext context, ThemeData theme) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => QrFullscreenDialog(
        promptpayId: promptpayId,
        amount: amount,
        currency: currency,
        overlayIcon: overlayIcon,
        cancelLabel: l10n.cancel,
      ),
    );
  }
}

class QrFullscreenDialog extends StatelessWidget {
  const QrFullscreenDialog({
    super.key,
    required this.promptpayId,
    required this.amount,
    required this.currency,
    required this.overlayIcon,
    required this.cancelLabel,
  });

  final String promptpayId;
  final double amount;
  final String currency;
  final String overlayIcon;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog.fullscreen(
      backgroundColor: AppColors.overlayBackground,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(28),
                child: PromptPayQrCode(
                  promptpayId: promptpayId,
                  amount: amount,
                  size: 320,
                  overlayIcon: overlayIcon,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$currency${amount.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.overlayIcon,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                promptpayId,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.overlayTextSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.overlayTextSecondary,
                ),
                label: Text(
                  cancelLabel,
                  style: const TextStyle(color: AppColors.overlayTextSecondary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
