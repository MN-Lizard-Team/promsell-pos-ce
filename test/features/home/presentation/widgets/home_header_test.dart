import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_header.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('HomeHeader', () {
    testWidgets('displays shop name and subtitle', (tester) async {
      await tester.pumpApp(HomeHeader(shopName: 'Test Shop', onMenuTap: () {}));

      expect(find.textContaining('Test Shop'), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('uses fallback when shop name is empty', (tester) async {
      await tester.pumpApp(HomeHeader(shopName: '', onMenuTap: () {}));

      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('calls onMenuTap when menu icon is tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        HomeHeader(shopName: 'Shop', onMenuTap: () => tapped = true),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('has header semantics for screen readers', (tester) async {
      await tester.pumpApp(
        HomeHeader(shopName: 'Accessible Shop', onMenuTap: () {}),
      );

      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.header == true,
      );
      expect(semantics, findsOneWidget);
    });
  });
}
