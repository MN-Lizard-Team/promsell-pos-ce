import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/main_dev.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Tests', () {
    testWidgets('Capture screenshots of 5 main tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final dir = Directory('/sdcard/screenshots');
      if (!dir.existsSync()) dir.createSync(recursive: true);

      await _captureScreenshot(tester, 'sale');
      await _tapNav(tester, 1);
      await tester.pumpAndSettle();
      await _captureScreenshot(tester, 'products');
      await _tapNav(tester, 2);
      await tester.pumpAndSettle();
      await _captureScreenshot(tester, 'history');
      await _tapNav(tester, 3);
      await tester.pumpAndSettle();
      await _captureScreenshot(tester, 'report');
      await _tapNav(tester, 4);
      await tester.pumpAndSettle();
      await _captureScreenshot(tester, 'settings');
    });
  });
}

Future<void> _tapNav(WidgetTester tester, int index) async {
  final navBar = find.byType(NavigationBar);
  final navRail = find.byType(NavigationRail);

  if (navBar.evaluate().isNotEmpty) {
    await tester.tap(
      find.descendant(of: navBar, matching: find.byIcon(_navIcon(index))),
    );
  } else if (navRail.evaluate().isNotEmpty) {
    await tester.tap(
      find.descendant(of: navRail, matching: find.byIcon(_navIcon(index))),
    );
  }
  await tester.pumpAndSettle();
}

IconData _navIcon(int index) {
  switch (index) {
    case 0:
      return Icons.point_of_sale_outlined;
    case 1:
      return Icons.inventory_2_outlined;
    case 2:
      return Icons.receipt_long_outlined;
    case 3:
      return Icons.bar_chart_outlined;
    case 4:
      return Icons.settings_outlined;
    default:
      return Icons.error;
  }
}

Future<void> _captureScreenshot(WidgetTester tester, String name) async {
  final binding = tester.binding;
  if (binding is! IntegrationTestWidgetsFlutterBinding) return;

  await binding.takeScreenshot(name);
  final results = binding.reportData;
  if (results == null) return;

  final screenshots = results['screenshots'] as List?;
  if (screenshots == null || screenshots.isEmpty) return;

  final last = screenshots.last as Map<String, dynamic>;
  final bytes = last['bytes'] as Uint8List?;
  if (bytes == null) return;

  final file = File('/sdcard/screenshots/$name.png');
  await file.writeAsBytes(bytes);
}
