import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';

void main() {
  Future<void> pumpHost(
    WidgetTester tester, {
    required Future<void> Function(BuildContext context) onOpen,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => onOpen(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('showConfirmationDialog (compat)', () {
    testWidgets('confirm returns true', (tester) async {
      bool? result;
      await pumpHost(
        tester,
        onOpen: (context) async {
          result = await showConfirmationDialog(
            context,
            title: 'Delete?',
            message: 'Really?',
            confirmLabel: 'Delete',
            cancelLabel: 'Cancel',
            destructive: true,
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('cancel returns false', (tester) async {
      bool? result;
      await pumpHost(
        tester,
        onOpen: (context) async {
          result = await showConfirmationDialog(
            context,
            title: 'Delete?',
            message: 'Really?',
            confirmLabel: 'Delete',
            cancelLabel: 'Cancel',
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('barrier dismiss returns false when enabled', (tester) async {
      bool? result;
      await pumpHost(
        tester,
        onOpen: (context) async {
          result = await showConfirmationDialog(
            context,
            title: 'Title',
            message: 'Body',
            confirmLabel: 'OK',
            cancelLabel: 'Cancel',
            barrierDismissible: true,
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('confirmIcon shows in header circle', (tester) async {
      await pumpHost(
        tester,
        onOpen: (context) async {
          await showConfirmationDialog(
            context,
            title: 'Delete?',
            message: 'Really?',
            confirmLabel: 'Delete',
            cancelLabel: 'Cancel',
            destructive: true,
            confirmIcon: Icons.delete_outline,
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byType(FilledButton), findsNWidgets(2));
    });

    testWidgets('custom cancel label is shown', (tester) async {
      await pumpHost(
        tester,
        onOpen: (context) async {
          await showConfirmationDialog(
            context,
            title: 'Title',
            message: 'Body',
            confirmLabel: 'OK',
            cancelLabel: 'No thanks',
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('No thanks'), findsOneWidget);
    });
  });
}
