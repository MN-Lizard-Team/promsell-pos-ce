import 'package:flutter_test/flutter_test.dart';

/// Base class for Robot pattern implementations
/// Provides common utilities and enforces consistent structure
abstract class RobotBase {
  RobotBase(this.tester);

  final WidgetTester tester;

  /// Wait and settle after action.
  ///
  /// Uses `pump` (not `pumpAndSettle`) because the app has continuous timers
  /// (clock, auto-refresh streams) that never settle — `pumpAndSettle` would
  /// block for the 10s default timeout on every call.
  Future<void> settle() async {
    await tester.pump(const Duration(milliseconds: 800));
  }

  /// Wait for duration
  Future<void> wait([
    Duration duration = const Duration(milliseconds: 500),
  ]) async {
    await tester.pump(duration);
  }

  /// Tap widget and settle
  Future<void> tap(Finder finder) async {
    await tester.tap(finder);
    await settle();
  }

  /// Enter text and settle
  Future<void> enterText(Finder finder, String text) async {
    await tester.enterText(finder, text);
    await settle();
  }

  /// Verify widget exists
  void expectVisible(Finder finder, {String? reason}) {
    expect(finder, findsOneWidget, reason: reason);
  }

  /// Verify widget does not exist
  void expectNotVisible(Finder finder, {String? reason}) {
    expect(finder, findsNothing, reason: reason);
  }

  /// Verify text exists
  void expectText(String text, {String? reason}) {
    expect(find.text(text), findsOneWidget, reason: reason);
  }
}
