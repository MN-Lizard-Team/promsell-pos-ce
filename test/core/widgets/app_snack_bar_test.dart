import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';

void main() {
  group('AppSnackBar', () {
    testWidgets('success shows overlay with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => AppSnackBar.success(context, 'Success!'),
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Success!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('error shows overlay with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => AppSnackBar.error(context, 'Error!'),
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Error!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('warning shows overlay with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => AppSnackBar.warning(context, 'Warning!'),
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Warning!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('info shows overlay with message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => AppSnackBar.info(context, 'Info!'),
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Info!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('withAction shows overlay with action button', (tester) async {
      var actionCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => AppSnackBar.withAction(
                    context,
                    'Item removed',
                    actionLabel: 'Undo',
                    onAction: () => actionCalled = true,
                  ),
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Item removed'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(actionCalled, isTrue);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('toast auto-dismisses after duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => AppSnackBar.info(
                    context,
                    'Quick',
                    duration: const Duration(milliseconds: 100),
                  ),
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Quick'), findsOneWidget);

      // Let the 100ms duration timer fire + 200ms fade-out complete
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Quick'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
    });
  });
}
