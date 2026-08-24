import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'robot_pattern/checkout_robot.dart';
import 'robot_pattern/sale_robot.dart';
import 'helpers/test_utils.dart';

/// Money-critical device journey: mixed tenders -> void -> reconciliation.
///
/// The PromptPay branch requires a configured PromptPay id and a device
/// capable of rendering the QR page. Host-side tender arithmetic is covered
/// by `test/integration/multi_tender_daily_close_test.dart`; this journey
/// verifies the actual navigation and keyed controls on a device.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey 6: Day close reconciliation', () {
    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);
      await TestApp.database
          .into(TestApp.database.appSettings)
          .insertOnConflictUpdate(
            const AppSettingsCompanion(
              key: Value('promptpayId'),
              value: Value('0812345678'),
            ),
          );
      await TestApp.database
          .into(TestApp.database.appSettings)
          .insertOnConflictUpdate(
            const AppSettingsCompanion(
              key: Value('dailyCloseLock'),
              value: Value('true'),
            ),
          );
    });

    tearDown(TestApp.dispose);

    testWidgets('cash + PromptPay, void, then close and lock the day', (
      tester,
    ) async {
      final sale = SaleRobot(tester);
      final checkout = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await sale.navigateToSalePage();

      // Cash sale: Coffee 45, drawer receives 100.
      await sale.addProductToCart('Coffee');
      await sale.proceedToCheckout();
      await checkout.selectPaymentMethod('Cash');
      await checkout.enterCashReceived(45);
      await checkout.completePayment();
      await checkout.closeReceipt();

      // PromptPay sale: Burger 120. The QR confirmation is deterministic
      // once the device is configured with the seeded PromptPay id.
      await sale.addProductToCart('Burger');
      await sale.proceedToCheckout();
      await checkout.selectPaymentMethod('PromptPay');
      await tester.pump(const Duration(milliseconds: 800));
      final promptPayConfirm = find.byKey(
        const Key(TestKeys.promptPayConfirmButton),
      );
      expect(promptPayConfirm, findsOneWidget);
      await tester.tap(promptPayConfirm);
      await tester.pump(const Duration(seconds: 2));
      await checkout.closeReceipt();

      // Navigate to report/history and void the PromptPay bill. The
      // sale-expansion tile is found by its dynamic database key.
      await tester.tap(find.byIcon(TablerIcons.chartBar).first);
      await tester.pump(const Duration(milliseconds: 800));
      final historyTab = find.byKey(const Key(TestKeys.historySubTabButton));
      expect(historyTab, findsOneWidget);
      await tester.tap(historyTab);
      await tester.pump(const Duration(milliseconds: 800));
      final saleTiles = find.byType(ExpansionTile);
      expect(saleTiles, findsWidgets);
      await tester.tap(saleTiles.first);
      await tester.pump(const Duration(milliseconds: 500));
      final voidButton = find.byKey(const Key(TestKeys.voidButton));
      expect(voidButton, findsOneWidget);
      await tester.tap(voidButton);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(
        find.byKey(const Key(TestKeys.voidReasonField)),
        'End of day correction',
      );
      await tester.tap(find.byKey(const Key(TestKeys.voidConfirmButton)));
      await tester.pump(const Duration(seconds: 1));

      // Return home and open daily close through the stable menu tile.
      await tester.tap(find.byIcon(Icons.home).first);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.tap(find.byKey(const Key(TestKeys.homeCloseDayTile)));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key(TestKeys.openingCashField)), findsOneWidget);
      expect(find.byKey(const Key(TestKeys.countedCashField)), findsOneWidget);
      final expected = find.byKey(const Key(TestKeys.expectedCashValue));
      expect(expected, findsOneWidget);

      // Opening 50 + cash sale 45. The voided PromptPay sale contributes
      // neither cash nor active revenue to the close calculation.
      await tester.enterText(
        find.byKey(const Key(TestKeys.openingCashField)),
        '50',
      );
      await tester.enterText(
        find.byKey(const Key(TestKeys.countedCashField)),
        '95',
      );
      await tester.tap(find.byKey(const Key(TestKeys.closeDayButton)));
      await tester.pump(const Duration(milliseconds: 500));
      final confirm = find.text('Confirm').or(find.text('ยืนยัน'));
      if (confirm.evaluate().isNotEmpty) {
        await tester.tap(confirm.first);
        await tester.pump(const Duration(milliseconds: 500));
      }

      expect(find.byKey(const Key(TestKeys.reopenDayButton)), findsOneWidget);
      expect(
        find.byKey(const Key(TestKeys.dailyCloseSummaryCard)),
        findsOneWidget,
      );
      final closeRows = await TestApp.database
          .select(TestApp.database.dailyCloses)
          .get();
      expect(closeRows, hasLength(1));
      expect(closeRows.single.closedAt != null, isTrue);
      expect(closeRows.single.expectedCash, 95.0);
    });
  });
}
