import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/bill_note_sheet.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    theme: ThemeData(extensions: const [PosThemeExtension.light]),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('BillNoteSheet', () {
    testWidgets('renders ticket sheet chrome not AlertDialog', (tester) async {
      await tester.pumpWidget(
        _wrap(BillNoteSheet(initialValue: '', onSave: (_) {})),
      );
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Bill note'), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_note_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_note_save')), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_note_close')), findsOneWidget);
    });

    testWidgets('prefills initial value', (tester) async {
      await tester.pumpWidget(
        _wrap(BillNoteSheet(initialValue: 'VIP table', onSave: (_) {})),
      );
      await tester.pump();

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('bill_note_field')),
      );
      expect(field.controller?.text, 'VIP table');
      expect(find.byKey(const ValueKey('bill_note_clear')), findsOneWidget);
    });

    testWidgets('save trims and calls onSave then pops when shown via sheet', (
      tester,
    ) async {
      String? saved;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [PosThemeExtension.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => BillNoteSheet.show(
                    context,
                    initialValue: '',
                    onSave: (n) => saved = n,
                  ),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(BillNoteSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('bill_note_field')),
        '  takeaway  ',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('bill_note_save')));
      await tester.pumpAndSettle();

      expect(saved, 'takeaway');
      expect(find.byType(BillNoteSheet), findsNothing);
    });

    testWidgets('clear empties field but keeps sheet open', (tester) async {
      await tester.pumpWidget(
        _wrap(BillNoteSheet(initialValue: 'old note', onSave: (_) {})),
      );
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('bill_note_clear')));
      await tester.pump();

      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('bill_note_field')),
      );
      expect(field.controller?.text, isEmpty);
      expect(find.byType(BillNoteSheet), findsOneWidget);
    });

    testWidgets('save empty string clears bill note', (tester) async {
      String? saved = 'sentinel';
      await tester.pumpWidget(
        _wrap(
          BillNoteSheet(initialValue: 'was here', onSave: (n) => saved = n),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const ValueKey('bill_note_field')),
        '   ',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('bill_note_save')));
      await tester.pumpAndSettle();

      expect(saved, '');
    });

    testWidgets('cancel does not call onSave', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [PosThemeExtension.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => BillNoteSheet.show(
                    context,
                    initialValue: 'keep',
                    onSave: (_) => called = true,
                  ),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('bill_note_field')),
        'changed',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('bill_note_cancel')));
      await tester.pumpAndSettle();

      expect(called, isFalse);
      expect(find.byType(BillNoteSheet), findsNothing);
    });

    testWidgets('showItemNote opens ticket sheet with product context', (
      tester,
    ) async {
      String? saved;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: ThemeData(extensions: const [PosThemeExtension.light]),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => BillNoteSheet.showItemNote(
                    context,
                    productName: 'Latte',
                    initialValue: 'less sugar',
                    onSave: (n) => saved = n,
                  ),
                  child: const Text('open item note'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open item note'));
      await tester.pumpAndSettle();

      expect(find.byType(BillNoteSheet), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const ValueKey('note_sheet_context')), findsOneWidget);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.byKey(const ValueKey('bill_note_field')), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('bill_note_field')),
        'no ice',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('bill_note_save')));
      await tester.pumpAndSettle();

      expect(saved, 'no ice');
      expect(find.byType(BillNoteSheet), findsNothing);
    });
  });
}
