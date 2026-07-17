import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_dialog_shell.dart';

void main() {
  Future<void> pumpHost(
    WidgetTester tester, {
    required Future<void> Function(BuildContext context) onOpen,
    Size surface = const Size(800, 1200),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D5D6B),
            error: const Color(0xFFDC2626),
            onError: Colors.white,
          ),
          useMaterial3: true,
        ),
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

  group('showAppConfirm', () {
    testWidgets('destructive shows circular delete header by default', (
      tester,
    ) async {
      await pumpHost(
        tester,
        onOpen: (context) async {
          await showAppConfirm(
            context,
            title: 'ลบรายการนี้ออกจากบิล?',
            message: '',
            detail: 'Hot Americano',
            footnote: 'จำนวน 2 ชิ้น',
            confirmLabel: 'ลบรายการ',
            cancelLabel: 'ยกเลิก',
            destructive: true,
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AppDialogShell), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.text('ลบรายการนี้ออกจากบิล?'), findsOneWidget);
      expect(find.text('Hot Americano'), findsOneWidget);
      expect(find.text('จำนวน 2 ชิ้น'), findsOneWidget);
    });

    testWidgets('confirm uses accent orange pill', (tester) async {
      await pumpHost(
        tester,
        onOpen: (context) async {
          await showAppConfirm(
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

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete'),
      );
      final bg = button.style?.backgroundColor?.resolve({});
      expect(bg, AppColors.accent);
    });

    testWidgets('confirm / cancel return bool', (tester) async {
      bool? result;
      await pumpHost(
        tester,
        onOpen: (context) async {
          result = await showAppConfirm(
            context,
            title: 'Go?',
            message: 'Continue',
            confirmLabel: 'Yes',
            cancelLabel: 'No',
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'No'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Yes'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('twin actions are side by side', (tester) async {
      await pumpHost(
        tester,
        surface: const Size(390, 800),
        onOpen: (context) async {
          await showAppConfirm(
            context,
            title: 'Clear cart?',
            message: 'All items will be removed.',
            confirmLabel: 'Clear',
            cancelLabel: 'Cancel',
            destructive: true,
          );
        },
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final clear = tester.getCenter(find.text('Clear'));
      final cancel = tester.getCenter(find.text('Cancel'));
      // Same row: similar Y, cancel left of confirm.
      expect((clear.dy - cancel.dy).abs(), lessThan(8));
      expect(cancel.dx, lessThan(clear.dx));
    });
  });
}
