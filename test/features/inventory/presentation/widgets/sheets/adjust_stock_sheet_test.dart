import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/widgets/sheets/adjust_stock_sheet.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class _MockAdjustStock extends Mock implements AdjustStock {}

class _MockAppLockService extends Mock implements AppLockService {}

void main() {
  late _MockAdjustStock adjustStock;
  late _MockAppLockService appLock;

  setUp(() async {
    await GetIt.I.reset();
    adjustStock = _MockAdjustStock();
    appLock = _MockAppLockService();
    when(() => appLock.isEnabled()).thenAnswer((_) async => false);
    when(
      () => adjustStock.call(
        productId: any(named: 'productId'),
        qtyChange: any(named: 'qtyChange'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async {});
    GetIt.I
      ..registerSingleton<AppLockService>(appLock)
      ..registerSingleton<AdjustStock>(adjustStock);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<Future<int?> Function()> openSheet(WidgetTester tester) async {
    late Future<int?> Function() open;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            open = () => showAdjustStockSheet(
              context,
              productId: 'p1',
              productName: 'Coffee',
              currentStock: 10,
              unit: 'pcs',
            );
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ),
    );
    return open;
  }

  Future<void> chooseRemoveAndReason(WidgetTester tester) async {
    await tester.tap(find.text('Remove'));
    await tester.enterText(find.byType(TextField).first, '3');
    await tester.tap(find.text('Damaged'));
    await tester.pump();
  }

  testWidgets('removes stock and closes without framework exceptions', (
    tester,
  ) async {
    final open = await openSheet(tester);
    final resultFuture = open();
    await tester.pumpAndSettle();

    await chooseRemoveAndReason(tester);
    expect(find.byKey(const ValueKey('adjust-stock-preview')), findsOneWidget);

    // Save button may be off-screen in the default 800x600 test viewport.
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('adjust-stock-save')));
    await tester.pumpAndSettle();

    expect(await resultFuture, 7);
    verify(
      () => adjustStock.call(productId: 'p1', qtyChange: -3, reason: 'Damaged'),
    ).called(1);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('adjust-stock-save')), findsNothing);
  });

  testWidgets('cancel while quantity field is focused closes cleanly', (
    tester,
  ) async {
    final open = await openSheet(tester);
    final resultFuture = open();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '3');
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await resultFuture, isNull);
    verifyNever(
      () => adjustStock.call(
        productId: any(named: 'productId'),
        qtyChange: any(named: 'qtyChange'),
        reason: any(named: 'reason'),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not submit a removal that would make stock negative', (
    tester,
  ) async {
    final open = await openSheet(tester);
    open();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Remove'));
    await tester.enterText(find.byType(TextField).first, '11');
    await tester.tap(find.text('Damaged'));
    await tester.pump();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('adjust-stock-save')),
      warnIfMissed: false,
    );
    await tester.pump();

    verifyNever(
      () => adjustStock.call(
        productId: any(named: 'productId'),
        qtyChange: any(named: 'qtyChange'),
        reason: any(named: 'reason'),
      ),
    );
    expect(find.byKey(const ValueKey('adjust-stock-save')), findsOneWidget);
  });
}
