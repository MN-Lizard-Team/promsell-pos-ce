import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_unsaved_dialog.dart';

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

  testWidgets('save / discard / cancel return correct actions', (tester) async {
    UnsavedDialogAction? result;
    await pumpHost(
      tester,
      onOpen: (context) async {
        result = await showAppUnsaved(
          context,
          title: 'Unsaved Changes',
          message: 'Leave without saving?',
          discardLabel: "Don't save",
          cancelLabel: 'Cancel',
          saveLabel: 'Save',
        );
      },
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(result, UnsavedDialogAction.save);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, "Don't save"));
    await tester.pumpAndSettle();
    expect(result, UnsavedDialogAction.discard);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(result, UnsavedDialogAction.cancel);
  });
}
