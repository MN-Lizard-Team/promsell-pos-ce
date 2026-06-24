import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_reconciliation_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DailyCloseReconciliationCard', () {
    testWidgets('renders reconciliation fields', (tester) async {
      final openingCtrl = TextEditingController(text: '500');
      final countedCtrl = TextEditingController(text: '1000');
      final noteCtrl = TextEditingController();

      await tester.pumpApp(
        DailyCloseReconciliationCard(
          openingController: openingCtrl,
          countedController: countedCtrl,
          noteController: noteCtrl,
          openingCash: 500,
          expectedCash: 1000,
          countedCash: 1000,
          overShort: 0,
          isReadOnly: false,
          onOpeningChanged: (_) {},
          onCountedChanged: (_) {},
          onNoteChanged: (_) {},
        ),
      );

      expect(find.byType(DailyCloseReconciliationCard), findsOneWidget);

      openingCtrl.dispose();
      countedCtrl.dispose();
      noteCtrl.dispose();
    });
  });
}
