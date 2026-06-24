import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_auto_open_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_formats_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_format_labels.dart';

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

  group('BarcodeAutoOpenTile', () {
    testWidgets('renders disabled label when delay is 0', (tester) async {
      await tester.pumpApp(
        BarcodeAutoOpenTile(
          settings: const Settings(),
          cubit: mockSettingsCubit,
          st: SettingsThemeExtension.light,
        ),
      );

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsOneWidget);
    });
  });

  group('BarcodeFormatsTile', () {
    testWidgets('renders tile with format count', (tester) async {
      await tester.pumpApp(
        BarcodeFormatsTile(
          settings: const Settings(),
          cubit: mockSettingsCubit,
          st: SettingsThemeExtension.light,
        ),
      );

      expect(find.byIcon(Icons.filter_list_outlined), findsOneWidget);
      expect(find.textContaining('/'), findsOneWidget);
    });

    testWidgets('opens formats dialog on tap', (tester) async {
      await tester.pumpApp(
        BarcodeFormatsTile(
          settings: const Settings(),
          cubit: mockSettingsCubit,
          st: SettingsThemeExtension.light,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(CheckboxListTile), findsWidgets);
      expect(find.text('Select all'), findsOneWidget);
      expect(find.text('Deselect all'), findsOneWidget);
    });
  });

  group('barcodeFormatLabel', () {
    testWidgets('returns label for known format', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Text(barcodeFormatLabel(context, 'ean13')),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('returns name for unknown format', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Text(barcodeFormatLabel(context, 'unknown')),
        ),
      );

      expect(find.text('unknown'), findsOneWidget);
    });
  });
}
