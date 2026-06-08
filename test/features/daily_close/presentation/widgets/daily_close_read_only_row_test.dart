import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/daily_close_read_only_row.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('DailyCloseReadOnlyRow', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpApp(
        const DailyCloseReadOnlyRow(
          label: 'Opening cash',
          value: Text('THB1,000'),
        ),
      );

      expect(find.text('Opening cash'), findsOneWidget);
      expect(find.text('THB1,000'), findsOneWidget);
    });
  });
}
