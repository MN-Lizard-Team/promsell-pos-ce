import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_menu_grid.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('HomeMenuGrid', () {
    testWidgets('renders 6 menu buttons', (tester) async {
      await tester.pumpApp(const HomeMenuGrid());

      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Promotions'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Close Day'), findsOneWidget);
    });

    testWidgets('calls onTap with correct HomeMenuItem when tapped', (
      tester,
    ) async {
      HomeMenuItem? tappedItem;

      await tester.pumpApp(
        HomeMenuGridTapHandler(
          onTap: (item) => tappedItem = item,
          child: const HomeMenuGrid(),
        ),
      );

      await tester.tap(find.text('Sale'));
      expect(tappedItem, HomeMenuItem.sell);

      await tester.tap(find.text('Products'));
      expect(tappedItem, HomeMenuItem.products);

      await tester.tap(find.text('Close Day'));
      expect(tappedItem, HomeMenuItem.closeDay);
    });
  });
}
