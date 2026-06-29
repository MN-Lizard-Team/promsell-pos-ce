import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_display_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_preferences_section.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('SalesDisplaySection', () {
    testWidgets('renders section title and switches', (tester) async {
      await tester.pumpApp(
        SalesDisplaySection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.text('DISPLAY'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('calls onUpdate with compact mode', (tester) async {
      Settings? updated;
      await tester.pumpApp(
        SalesDisplaySection(
          settings: const Settings(),
          onUpdate: (s) => updated = s,
        ),
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.cartCompactMode, isFalse);
    });
  });

  group('SalesPreferencesSection', () {
    testWidgets('renders currency and date format choices', (tester) async {
      await tester.pumpApp(
        SalesPreferencesSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(7));
    });

    testWidgets('renders drafts tile with value', (tester) async {
      await tester.pumpApp(
        SalesPreferencesSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.textContaining('30'), findsOneWidget);
    });
  });
}
