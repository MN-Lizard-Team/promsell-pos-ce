import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/daily_close_date_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('DailyCloseDateCard', () {
    testWidgets('renders formatted date and OPEN chip', (tester) async {
      await tester.pumpApp(
        const DailyCloseDateCard(date: '2026-06-08', isReadOnly: false),
      );

      expect(find.text('08/06/2026'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('renders CLOSED chip when read only', (tester) async {
      await tester.pumpApp(
        const DailyCloseDateCard(date: '2026-06-07', isReadOnly: true),
      );

      expect(find.text('07/06/2026'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
    });
  });
}
