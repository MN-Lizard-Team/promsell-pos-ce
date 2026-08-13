import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common test utilities for E2E tests
class TestUtils {
  TestUtils._();

  /// Wait for a widget to appear with timeout
  static Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle(pollInterval);

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    throw TestFailure(
      'Widget not found after ${timeout.inSeconds}s: ${finder.toString()}',
    );
  }

  /// Wait for widget to disappear
  static Future<void> waitForDisappear(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle(pollInterval);

      if (finder.evaluate().isEmpty) {
        return;
      }
    }

    throw TestFailure(
      'Widget still visible after ${timeout.inSeconds}s: ${finder.toString()}',
    );
  }

  /// Tap and wait for animations
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enter text and wait
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scroll until visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder,
    Finder scrollable, {
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    for (var i = 0; i < maxScrolls; i++) {
      if (finder.evaluate().isNotEmpty) {
        await tester.ensureVisible(finder);
        return;
      }

      await tester.drag(scrollable, Offset(0, -delta));
      await tester.pumpAndSettle();
    }

    throw TestFailure(
      'Widget not found after $maxScrolls scrolls: ${finder.toString()}',
    );
  }

  /// Navigate to tab by icon
  static Future<void> navigateToTab(WidgetTester tester, IconData icon) async {
    final navBar = find.byType(NavigationBar);
    final navRail = find.byType(NavigationRail);

    if (navBar.evaluate().isNotEmpty) {
      await tester.tap(
        find.descendant(of: navBar, matching: find.byIcon(icon)),
      );
    } else if (navRail.evaluate().isNotEmpty) {
      await tester.tap(
        find.descendant(of: navRail, matching: find.byIcon(icon)),
      );
    } else {
      throw TestFailure('Navigation bar or rail not found');
    }

    await tester.pumpAndSettle();
  }

  /// Find button by text (handles various button types)
  static Finder findButton(String text) {
    return find
        .widgetWithText(ElevatedButton, text)
        .or(find.widgetWithText(TextButton, text))
        .or(find.widgetWithText(FilledButton, text))
        .or(find.widgetWithText(OutlinedButton, text));
  }

  /// Print widget tree for debugging
  static void debugPrintWidgetTree(WidgetTester tester) {
    debugPrint(tester.allWidgets.toString());
  }

  /// Wait for BLoC state change
  static Future<void> waitForBlocState(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pump(timeout);
    await tester.pumpAndSettle();
  }
}

/// Extension to add .or() and .and() methods to Finder
extension FinderExtensions on Finder {
  Finder or(Finder other) {
    return FinderOr(this, other);
  }

  Finder and(Finder other) {
    return FinderAnd(this, other);
  }
}

class FinderOr extends Finder {
  FinderOr(this.first, this.second);
  @override
  final Finder first;
  final Finder second;

  @override
  Iterable<Element> findInCandidates(Iterable<Element> candidates) {
    final firstResults = first.findInCandidates(candidates);
    if (firstResults.isNotEmpty) return firstResults;
    return second.findInCandidates(candidates);
  }

  @override
  String describeMatch(Plurality plurality) {
    final firstDesc = first.describeMatch(plurality);
    final secondDesc = second.describeMatch(plurality);
    return '$firstDesc OR $secondDesc';
  }

  @override
  String get description => describeMatch(Plurality.zero);
}

class FinderAnd extends Finder {
  FinderAnd(this.first, this.second);
  @override
  final Finder first;
  final Finder second;

  @override
  Iterable<Element> findInCandidates(Iterable<Element> candidates) {
    return first.findInCandidates(second.findInCandidates(candidates).toSet());
  }

  @override
  String describeMatch(Plurality plurality) {
    final firstDesc = first.describeMatch(plurality);
    final secondDesc = second.describeMatch(plurality);
    return '$firstDesc AND $secondDesc';
  }

  @override
  String get description => describeMatch(Plurality.zero);
}
