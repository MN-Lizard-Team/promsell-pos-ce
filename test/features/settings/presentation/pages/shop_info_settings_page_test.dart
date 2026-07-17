import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: Settings(
          shopInfo: ShopInfo(
            name: 'Shop',
            address: 'Addr',
            phone: '0812345678',
          ),
        ),
      ),
    );
  });

  testWidgets('Shop page uses chrome, form section, sticky save', (
    tester,
  ) async {
    await tester.pumpApp(
      const ShopInfoSettingsPage(),
      settingsCubit: mockSettingsCubit,
    );

    expect(find.byType(SettingsLeafChrome), findsOneWidget);
    expect(find.byType(FormSectionCard), findsOneWidget);
    expect(find.byType(StickyActionBar), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
