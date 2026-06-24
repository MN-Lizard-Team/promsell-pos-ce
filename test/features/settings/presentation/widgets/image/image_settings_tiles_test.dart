import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/image_quality_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/image_width_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/image_settings_labels.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  group('ImageQualityTile', () {
    testWidgets('renders quality value', (tester) async {
      await tester.pumpApp(
        ImageQualityTile(settings: const Settings(), cubit: mockSettingsCubit),
      );

      expect(find.byIcon(Icons.high_quality_outlined), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('opens quality dialog on tap', (tester) async {
      await tester.pumpApp(
        ImageQualityTile(settings: const Settings(), cubit: mockSettingsCubit),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });
  });

  group('ImageWidthTile', () {
    testWidgets('renders width value', (tester) async {
      await tester.pumpApp(
        ImageWidthTile(settings: const Settings(), cubit: mockSettingsCubit),
      );

      expect(find.byIcon(Icons.width_normal_outlined), findsOneWidget);
      expect(find.text('800px'), findsOneWidget);
    });

    testWidgets('opens width dialog on tap', (tester) async {
      await tester.pumpApp(
        ImageWidthTile(settings: const Settings(), cubit: mockSettingsCubit),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });
  });

  group('image settings labels', () {
    test('qualityLabel returns correct labels', () {
      expect(qualityLabel(50), 'Draft quality');
      expect(qualityLabel(70), 'Standard quality');
      expect(qualityLabel(80), 'High quality');
      expect(qualityLabel(90), 'Best quality');
      expect(qualityLabel(100), 'Original quality');
    });

    test('widthLabel returns correct labels', () {
      expect(widthLabel(400), 'Small size');
      expect(widthLabel(600), 'Medium size');
      expect(widthLabel(800), 'Large size');
      expect(widthLabel(1200), 'Extra large size');
      expect(widthLabel(1600), 'Full HD size');
    });
  });
}
