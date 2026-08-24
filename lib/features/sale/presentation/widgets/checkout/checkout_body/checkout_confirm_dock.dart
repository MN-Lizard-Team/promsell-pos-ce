import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

/// Full-bleed confirm dock — cart continuum (ticket paper + single dock lift).
class CheckoutConfirmDock extends StatelessWidget {
  const CheckoutConfirmDock({
    super.key,
    required this.currency,
    required this.effectiveTotal,
    required this.canConfirm,
    required this.submitted,
    required this.onConfirm,
  });

  final String currency;
  final double effectiveTotal;
  final bool canConfirm;
  final bool submitted;
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
      child: Material(
        elevation: pos.elevFlat,
        color: pos.billStubPaper,
        surfaceTintColor: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (_, checkoutState) {
                final isProcessing =
                    checkoutState.status == CheckoutStatus.processing;
                final busy = isProcessing || submitted;
                final enabled = !busy && canConfirm;

                return FilledButton.icon(
                  key: const Key(TestKeys.checkoutConfirmButton),
                  style: FilledButton.styleFrom(
                    minimumSize: Size(0, pos.ctaMinHeight),
                    backgroundColor: pos.ctaFill,
                    foregroundColor: pos.ctaOnFill,
                    disabledBackgroundColor: pos.ctaFill.withValues(alpha: 0.4),
                    disabledForegroundColor: pos.ctaOnFill.withValues(
                      alpha: 0.7,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'NotoSansThai',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: enabled
                      ? () {
                          HapticFeedback.mediumImpact();
                          onConfirm();
                        }
                      : null,
                  icon: busy
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: pos.ctaOnFill,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 24),
                  label: Text(
                    context.l10n.confirmPaymentAmount(
                      currency,
                      CurrencyFormatter.formatGrouped(effectiveTotal),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
