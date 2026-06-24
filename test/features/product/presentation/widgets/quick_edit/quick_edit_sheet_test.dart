import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/quick_edit_sheet.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

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

  group('QuickEditSheet', () {
    testWidgets('renders name field', (tester) async {
      await tester.pumpApp(
        const QuickEditSheet(
          field: QuickEditField.name,
          initialValue: 'Coffee',
        ),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders stock stepper', (tester) async {
      await tester.pumpApp(
        const QuickEditSheet(field: QuickEditField.stock, initialValue: '10'),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(StockStepper), findsOneWidget);
    });
  });
}
