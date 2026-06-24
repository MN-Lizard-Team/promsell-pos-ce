import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/rows/daily_close_summary_row.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DailyCloseSummaryRow', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpApp(
        const DailyCloseSummaryRow(label: 'Sales count', value: Text('42')),
      );

      expect(find.text('Sales count'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });
}
