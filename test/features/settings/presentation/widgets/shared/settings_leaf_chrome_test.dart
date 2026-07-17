import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('SettingsLeafChrome', () {
    testWidgets('constrains body to maxWidth 720 and shows header + children', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const SettingsLeafChrome(
          title: 'Leaf',
          header: Text('HEADER_SLOT'),
          children: [Text('CHILD_A'), Text('CHILD_B')],
        ),
      );

      expect(find.text('Leaf'), findsOneWidget);
      expect(find.text('HEADER_SLOT'), findsOneWidget);
      expect(find.text('CHILD_A'), findsOneWidget);
      expect(find.text('CHILD_B'), findsOneWidget);

      final constrained = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      expect(constrained.any((c) => c.constraints.maxWidth == 720), isTrue);
    });

    testWidgets('renders AppBar title from chrome', (tester) async {
      await tester.pumpApp(
        const SettingsLeafChrome(
          title: 'Gaps',
          children: [Text('ONE'), Text('TWO')],
        ),
      );

      expect(find.text('Gaps'), findsOneWidget);
      expect(find.text('ONE'), findsOneWidget);
      expect(find.text('TWO'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
