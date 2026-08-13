import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/promptpay_payment_page/promptpay_slip_handler.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  testWidgets('scheduleAutoConfirm fires onConfirm after 2s', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PromptPaySlipHandler.scheduleAutoConfirm(context, () {
                    confirmed++;
                  });
                },
                child: const Text('go'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump(); // schedule timer + snack
    expect(confirmed, 0);

    await tester.pump(const Duration(seconds: 2));
    expect(confirmed, 1);

    // Let snack duration finish to avoid pending timers.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('scheduleAutoConfirm cancel action prevents fire', (
    tester,
  ) async {
    var confirmed = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  PromptPaySlipHandler.scheduleAutoConfirm(context, () {
                    confirmed++;
                  });
                },
                child: const Text('go'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();

    final action = find.byType(TextButton);
    expect(action, findsOneWidget);
    await tester.tap(action);
    await tester.pump();

    await tester.pump(const Duration(seconds: 3));
    expect(confirmed, 0);
  });

  test('Timer cancel before fire prevents callback (Wave P1 mirror)', () {
    var confirmed = 0;
    final timer = Timer(const Duration(seconds: 2), () => confirmed++);
    timer.cancel();
    // No pump needed — cancelled timer never runs.
    expect(timer.isActive, isFalse);
    expect(confirmed, 0);
  });
}
