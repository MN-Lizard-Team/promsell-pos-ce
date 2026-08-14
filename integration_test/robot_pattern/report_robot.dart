import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper for interacting with the Report page in integration tests.
///
/// Locators are localized labels (the app icon set is tabler_icons_plus, so
/// raw `Icons.*` glyphs are unreliable for nav taps).
class ReportRobot {
  const ReportRobot(this.tester);

  final WidgetTester tester;

  /// Taps a date preset chip by its localized label.
  Future<void> selectPreset(String label) async {
    await tester.tap(find.text(label).first);
    await tester.pump(const Duration(milliseconds: 800));
  }

  /// Taps the "Custom" chip to open the date range picker.
  Future<void> openCustomRange({required String label}) async {
    await tester.tap(find.text(label).first);
    await tester.pump(const Duration(milliseconds: 800));
  }

  /// Switches to the History sub-tab using its localized label.
  Future<void> switchToHistory({required String label}) async {
    await tester.tap(find.text(label).first);
    await tester.pump(const Duration(milliseconds: 800));
  }

  /// Switches to the Report sub-tab using its localized label.
  Future<void> switchToReport({required String label}) async {
    await tester.tap(find.text(label).first);
    await tester.pump(const Duration(milliseconds: 800));
  }

  /// Verifies report cards are visible.
  Future<void> verifyNetRevenueVisible() async {
    expect(find.byType(Card), findsWidgets);
  }

  /// Pulls to refresh the report.
  Future<void> pullToRefresh() async {
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 300),
    );
    await tester.pump(const Duration(milliseconds: 800));
  }
}
