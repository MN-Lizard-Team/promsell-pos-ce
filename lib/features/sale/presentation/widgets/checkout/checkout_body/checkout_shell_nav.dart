import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';

/// Pops PromptPay / payment shell routes until the sale host remains.
abstract final class CheckoutShellNav {
  CheckoutShellNav._();

  static void popCheckoutShells(
    NavigatorState nav, {
    required bool includePromptPay,
  }) {
    var poppedPrompt = false;
    var poppedShell = false;
    while (nav.canPop()) {
      final name = ModalRoute.of(nav.context)?.settings.name;
      if (includePromptPay &&
          !poppedPrompt &&
          name == SalePaymentRoutes.promptPay) {
        nav.pop();
        poppedPrompt = true;
        continue;
      }
      if (!poppedShell &&
          (SalePaymentRoutes.isPaymentPage(name) ||
              name == SalePaymentRoutes.checkoutPage)) {
        nav.pop();
        poppedShell = true;
        break;
      }
      // Fallback when route names missing (tests / legacy): pop once or twice.
      if (name == null || !SalePaymentRoutes.isCheckoutShell(name)) {
        if (includePromptPay && !poppedPrompt) {
          nav.pop();
          poppedPrompt = true;
          if (nav.canPop()) {
            nav.pop();
            poppedShell = true;
          }
        } else if (!poppedShell && nav.canPop()) {
          nav.pop();
          poppedShell = true;
        }
        break;
      }
      break;
    }
  }

  /// Pop only the PromptPay route when still on top (cancel / failure mid-flow).
  static void popPromptPayIfOnTop(NavigatorState nav) {
    final name = ModalRoute.of(nav.context)?.settings.name;
    if (nav.canPop() && (name == SalePaymentRoutes.promptPay || name == null)) {
      nav.pop();
    }
  }
}
