import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/green_choice_chip.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('GreenChoiceChip', () {
    testWidgets('calls onSelected when tapped', (tester) async {
      var selected = false;
      await tester.pumpApp(
        GreenChoiceChip(
          label: const Text('Option A'),
          selected: false,
          onSelected: (value) => selected = value,
        ),
      );

      await tester.tap(find.byType(GreenChoiceChip));
      await tester.pump();

      expect(selected, isTrue);
    });

    testWidgets('renders label text', (tester) async {
      await tester.pumpApp(
        GreenChoiceChip(
          label: const Text('Test Label'),
          selected: false,
          onSelected: (_) {},
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });
  });
}
