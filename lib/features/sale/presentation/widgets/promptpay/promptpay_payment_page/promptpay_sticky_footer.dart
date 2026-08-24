import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// PromptPay cancel + confirm dock — money CTA uses [PosThemeExtension.ctaFill].
class PromptPayStickyFooter extends StatelessWidget {
  const PromptPayStickyFooter({
    super.key,
    required this.l10n,
    required this.onCancel,
    required this.onConfirm,
  });

  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final pos = context.posTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: pos.billStubPaper,
        border: Border(top: BorderSide(color: pos.billStubBorder)),
        boxShadow: pos.shadowDockUp,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, pos.ctaMinHeight),
                    foregroundColor: pos.parkCtaForeground,
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: FilledButton(
                  key: const Key(TestKeys.promptPayConfirmButton),
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(0, pos.ctaMinHeight),
                    backgroundColor: pos.ctaFill,
                    foregroundColor: pos.ctaOnFill,
                    textStyle: const TextStyle(
                      fontFamily: 'NotoSansThai',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(l10n.promptpayConfirmPayment),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
