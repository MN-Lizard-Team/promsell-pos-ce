import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/promptpay_payment_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_shell_nav.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/sale_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Mutable flags shared between checkout body and [CheckoutStatusListener].
class CheckoutFlowFlags {
  bool submitted = false;
  bool inPaymentFlow = false;
  Timer? processingTimeoutTimer;

  void startProcessingTimeout(BuildContext ctx) {
    processingTimeoutTimer?.cancel();
    processingTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (!ctx.mounted) return;
      // Do not unlock submitted while CreateSale may still complete.
      AppSnackBar.error(ctx, ctx.l10n.saleTimeout);
    });
  }

  void cancelProcessingTimeout() {
    processingTimeoutTimer?.cancel();
    processingTimeoutTimer = null;
  }

  void dispose() {
    cancelProcessingTimeout();
  }
}

/// Listens to [CheckoutBloc] status and navigates PromptPay / success / errors.
class CheckoutStatusListener extends StatelessWidget {
  const CheckoutStatusListener({
    super.key,
    required this.flags,
    required this.effectiveTotal,
    required this.localizeError,
    required this.onFlagsChanged,
    required this.child,
  });

  final CheckoutFlowFlags flags;
  final double effectiveTotal;
  final String Function(BuildContext ctx, String? key) localizeError;
  final VoidCallback onFlagsChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          (curr.status == CheckoutStatus.failure ||
              curr.status == CheckoutStatus.success ||
              curr.status == CheckoutStatus.waitingPayment ||
              curr.status == CheckoutStatus.idle ||
              curr.status == CheckoutStatus.processing),
      listener: (ctx, state) {
        if (state.status == CheckoutStatus.processing) {
          flags.startProcessingTimeout(ctx);
          return;
        }
        if (state.status == CheckoutStatus.waitingPayment) {
          flags.inPaymentFlow = true;
          flags.cancelProcessingTimeout();
          final cartState = ctx.read<CartBloc>().state;
          final settings = ctx.read<SettingsCubit>().state.settings;
          final qrTotal = state.promptPayAmount ?? effectiveTotal;
          Navigator.of(ctx).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: SalePaymentRoutes.promptPay),
              builder: (_) => PromptPayPaymentPage(
                total: qrTotal,
                billTotal:
                    (state.promptPayAmount != null &&
                        (state.promptPayAmount! - effectiveTotal).abs() > 0.009)
                    ? effectiveTotal
                    : null,
                currency: settings.currency,
                promptpayId: settings.promptpayId,
                settings: settings,
                bloc: ctx.read<CheckoutBloc>(),
                items: state.frozenItems ?? cartState.items,
              ),
            ),
          );
          return;
        }
        if (state.status == CheckoutStatus.success) {
          flags.cancelProcessingTimeout();
          final wasInFlow = flags.inPaymentFlow;
          flags.inPaymentFlow = false;
          flags.submitted = false;
          onFlagsChanged();
          final sale = state.lastSale;
          final settings = ctx.read<SettingsCubit>().state.settings;
          final checkoutBloc = ctx.read<CheckoutBloc>();
          final nav = Navigator.of(ctx);

          final hostContext = nav.context;

          CheckoutShellNav.popCheckoutShells(nav, includePromptPay: wasInFlow);

          checkoutBloc.add(const CheckoutReset());

          final showReceipt =
              sale != null &&
              settings.showPostSalePreview &&
              settings.receiptPreviewStyle != 'none';
          if (showReceipt) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!hostContext.mounted) return;
              SaleReceiptDialog.show(hostContext, sale, settings);
            });
          }
          return;
        }
        if (state.status == CheckoutStatus.idle && flags.inPaymentFlow) {
          flags.cancelProcessingTimeout();
          flags.inPaymentFlow = false;
          flags.submitted = false;
          onFlagsChanged();
          CheckoutShellNav.popPromptPayIfOnTop(Navigator.of(ctx));
          return;
        }
        if (state.status == CheckoutStatus.failure) {
          flags.cancelProcessingTimeout();
          final wasInFlow = flags.inPaymentFlow;
          flags.inPaymentFlow = false;
          flags.submitted = false;
          onFlagsChanged();
          if (wasInFlow) {
            CheckoutShellNav.popPromptPayIfOnTop(Navigator.of(ctx));
          }
          final msg = localizeError(ctx, state.errorMessage);
          AppSnackBar.error(ctx, msg);
        }
      },
      child: child,
    );
  }
}
