import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/payment_method_selector.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  Future<void> pumpSelector(
    WidgetTester tester, {
    required String method,
    required bool promptpay,
    required ValueChanged<String> onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: PaymentMethodSelector(
              method: method,
              promptpayEnabled: promptpay,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders 2x2 grid key and three methods without PromptPay', (
    tester,
  ) async {
    await pumpSelector(
      tester,
      method: 'cash',
      promptpay: false,
      onChanged: (_) {},
    );

    expect(
      find.byKey(const ValueKey('sale_payment_method_grid')),
      findsOneWidget,
    );
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('PromptPay'), findsNothing);
  });

  testWidgets('includes PromptPay when enabled', (tester) async {
    await pumpSelector(
      tester,
      method: 'card',
      promptpay: true,
      onChanged: (_) {},
    );

    expect(find.text('PromptPay'), findsOneWidget);
  });

  testWidgets('tapping transfer notifies onChanged', (tester) async {
    String? picked;
    await pumpSelector(
      tester,
      method: 'cash',
      promptpay: false,
      onChanged: (m) => picked = m,
    );

    await tester.tap(find.text('Transfer'));
    await tester.pump();
    expect(picked, 'transfer');
  });
}
