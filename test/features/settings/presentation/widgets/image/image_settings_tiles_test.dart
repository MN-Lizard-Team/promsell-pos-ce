import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/image_quality_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/image_width_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/image_settings_labels.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;
  final l10n = lookupAppLocalizations(const Locale('en'));

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

      expect(find.byIcon(TablerIcons.star), findsOneWidget);
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

      expect(find.byIcon(TablerIcons.arrowsHorizontal), findsOneWidget);
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
      expect(qualityLabel(50, l10n), l10n.imageQualityDraft);
      expect(qualityLabel(70, l10n), l10n.imageQualityStandard);
      expect(qualityLabel(80, l10n), l10n.imageQualityHigh);
      expect(qualityLabel(90, l10n), l10n.imageQualityBest);
      expect(qualityLabel(100, l10n), l10n.imageQualityOriginal);
    });

    test('widthLabel returns correct labels', () {
      expect(widthLabel(400, l10n), l10n.imageWidthSmall);
      expect(widthLabel(600, l10n), l10n.imageWidthMedium);
      expect(widthLabel(800, l10n), l10n.imageWidthLarge);
      expect(widthLabel(1200, l10n), l10n.imageWidthExtraLarge);
      expect(widthLabel(1600, l10n), l10n.imageWidthFullHD);
    });
  });
}
