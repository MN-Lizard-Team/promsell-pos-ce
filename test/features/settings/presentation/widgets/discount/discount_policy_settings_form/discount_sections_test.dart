import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_toggles_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_default_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_limits_section.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('DiscountTogglesSection', () {
    testWidgets('renders section title and switches', (tester) async {
      await tester.pumpApp(
        DiscountTogglesSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.text('TOGGLES'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('calls onUpdate when toggled', (tester) async {
      Settings? updated;
      await tester.pumpApp(
        DiscountTogglesSection(
          settings: const Settings(),
          onUpdate: (s) => updated = s,
        ),
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.enableItemDiscount, isFalse);
    });
  });

  group('DiscountDefaultSection', () {
    testWidgets('renders choice row with options', (tester) async {
      await tester.pumpApp(
        DiscountDefaultSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(2));
    });
  });

  group('DiscountLimitsSection', () {
    testWidgets('renders limit tiles', (tester) async {
      await tester.pumpApp(
        DiscountLimitsSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.text('LIMITS'), findsOneWidget);
      expect(find.byIcon(Icons.percent_outlined), findsOneWidget);
      expect(find.byIcon(Icons.trending_down_outlined), findsOneWidget);
    });

    testWidgets('shows no limit when amount is 0', (tester) async {
      await tester.pumpApp(
        DiscountLimitsSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.textContaining('No limit'), findsOneWidget);
    });
  });
}
