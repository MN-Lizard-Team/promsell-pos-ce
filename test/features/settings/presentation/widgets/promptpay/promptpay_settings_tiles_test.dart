import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_settings_tiles.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_overlay_icon_picker.dart';

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

  group('PromptpaySettingsTiles', () {
    testWidgets('renders all tiles', (tester) async {
      await tester.pumpApp(
        PromptpaySettingsTiles(
          settings: const Settings(),
          cubit: mockSettingsCubit,
          st: SettingsThemeExtension.light,
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('toggles sound switch', (tester) async {
      await tester.pumpApp(
        PromptpaySettingsTiles(
          settings: const Settings(),
          cubit: mockSettingsCubit,
          st: SettingsThemeExtension.light,
        ),
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      verify(() => mockSettingsCubit.updateField(any())).called(1);
    });
  });

  group('PromptpayOverlayIconPicker', () {
    testWidgets('renders all icon chips', (tester) async {
      await tester.pumpApp(
        PromptpayOverlayIconPicker(
          settings: const Settings(),
          cubit: mockSettingsCubit,
        ),
      );

      expect(find.byType(Icon), findsNWidgets(9));
    });

    testWidgets('calls cubit on tap', (tester) async {
      await tester.pumpApp(
        PromptpayOverlayIconPicker(
          settings: const Settings(),
          cubit: mockSettingsCubit,
        ),
      );

      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pump();
      verify(() => mockSettingsCubit.updateField(any())).called(1);
    });
  });
}
