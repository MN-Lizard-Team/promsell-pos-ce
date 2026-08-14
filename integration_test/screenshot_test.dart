import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';

/// Captures Play Store screenshots in both EN and TH locales.
///
/// 5 screens × 2 locales = 10 screenshots:
///   01_home      — Home tab
///   02_sale      — Sale tab (product catalog)
///   03_products  — Products tab
///   04_report    — Report tab
///   05_settings  — Settings tab
///
/// Run on emulator:
///   flutter test integration_test/screenshot_test.dart --flavor dev -d emulator-5554
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot capture (EN + TH)', () {
    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);
    });

    tearDown(() async {
      await TestApp.dispose();
    });

    for (final locale in ['en', 'th']) {
      testWidgets('Capture 5 screenshots — $locale', (tester) async {
        final binding = tester.binding;
        if (binding is IntegrationTestWidgetsFlutterBinding) {
          await binding.convertFlutterSurfaceToImage();
        }

        // Start the app (pumpApp skips re-init since setUp already called it).
        await TestApp.pumpApp(tester);

        // Set locale AFTER pumpApp so SettingsCubit is registered in DI.
        // AH-1.4: Settings locale is now a String (e.g. 'en', 'th') stored
        // as `localeCode` on the flat copyWith, not a Flutter Locale.
        final cubit = sl<SettingsCubit>();
        cubit.updateField((s) => s.copyWith(localeCode: locale));
        await tester.pump(const Duration(seconds: 1));

        // Wait for home page FutureBuilder + ProductBloc to finish loading
        // so the screenshot doesn't capture a skeleton/loading state.
        // Pump until no Shimmer widgets are present (or 10s timeout).
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          final hasShimmer = find.byType(Shimmer).evaluate().isNotEmpty;
          if (!hasShimmer && i > 4) break;
        }

        final outDir = await _outputDir(locale);

        // 01 — Home (app starts on home tab)
        await _capture(tester, outDir, '01_home');

        // 02 — Sale
        await _goToTab(tester, 2);
        await _capture(tester, outDir, '02_sale');

        // 03 — Products
        await _goToTab(tester, 1);
        await _capture(tester, outDir, '03_products');

        // 04 — Report
        await _goToTab(tester, 3);
        await _capture(tester, outDir, '04_report');

        // 05 — Settings
        await _goToTab(tester, 4);
        await _capture(tester, outDir, '05_settings');
      });
    }
  });
}

//  Helpers

/// Nav tab icons — must match MainShell._pageBuilders order.
const _navIcons = <IconData>[
  Icons.home_outlined, // 0: Home
  TablerIcons.cube, // 1: Products
  TablerIcons.buildingStore, // 2: Sale
  TablerIcons.chartBar, // 3: Report
  Icons.settings_outlined, // 4: Settings
];

Future<void> _goToTab(WidgetTester tester, int index) async {
  final icon = _navIcons[index];
  final finder = find.byIcon(icon);
  // Wait up to 5s for the icon to appear.
  final end = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) break;
  }
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder.first);
    // Pump until no Shimmer widgets (loading done) or 5s timeout.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      final hasShimmer = find.byType(Shimmer).evaluate().isNotEmpty;
      if (!hasShimmer && i > 1) break;
    }
  }
}

Future<Directory> _outputDir(String locale) async {
  final base = await getExternalStorageDirectory();
  final basePath = base?.path ?? '/data/local/tmp';
  final dir = Directory('$basePath/screenshots/$locale');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return dir;
}

Future<void> _capture(
  WidgetTester tester,
  Directory outDir,
  String name,
) async {
  final binding = tester.binding;
  if (binding is! IntegrationTestWidgetsFlutterBinding) return;

  await binding.takeScreenshot(name);
  await tester.pump(const Duration(milliseconds: 500));

  final results = binding.reportData;
  if (results == null) return;

  final screenshots = results['screenshots'] as List?;
  if (screenshots == null || screenshots.isEmpty) return;

  final last = screenshots.last as Map<String, dynamic>;
  final bytes = last['bytes'] as Uint8List?;
  if (bytes == null) return;

  final file = File('${outDir.path}/$name.png');
  await file.writeAsBytes(bytes);
}
