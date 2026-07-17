import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/checkout_shell_nav.dart';

void main() {
  testWidgets('popCheckoutShells pops payment sheet by name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: SalePaymentRoutes.checkoutPage,
                      ),
                      builder: (_) => const Scaffold(
                        body: Text('checkout-shell'),
                      ),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('checkout-shell'), findsOneWidget);

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    CheckoutShellNav.popCheckoutShells(nav, includePromptPay: false);
    await tester.pumpAndSettle();
    expect(find.text('checkout-shell'), findsNothing);
  });
}
