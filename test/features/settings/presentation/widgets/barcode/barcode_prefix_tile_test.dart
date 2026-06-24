import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_prefix_tile.dart';

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

  group('BarcodePrefixTile', () {
    testWidgets('renders prefix value', (tester) async {
      const settings = Settings(
        barcodeConfig: BarcodeConfig(autoGeneratePrefix: '890'),
      );
      await tester.pumpApp(
        BarcodePrefixTile(settings: settings, cubit: mockSettingsCubit),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('890'), findsOneWidget);
    });

    testWidgets('opens prefix dialog on tap', (tester) async {
      const settings = Settings();
      await tester.pumpApp(
        BarcodePrefixTile(settings: settings, cubit: mockSettingsCubit),
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
