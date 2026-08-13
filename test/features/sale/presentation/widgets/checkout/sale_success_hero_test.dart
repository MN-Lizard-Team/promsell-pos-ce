import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/sale_success_hero.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final tNow = DateTime(2025, 1, 15, 10, 30);

  Sale cashSale({Money? change}) => Sale(
    id: 'sale-0001',
    receiptNumber: 'R-100',
    totalAmount: Money.fromDouble(200),
    subtotalAmount: Money.fromDouble(200),
    paymentMethod: 'cash',
    amountReceived: Money.fromDouble(500),
    changeAmount: change ?? Money.fromDouble(300),
    createdAt: tNow,
    items: const [],
  );

  Sale cardSale() => Sale(
    id: 'sale-0002',
    receiptNumber: 'R-101',
    totalAmount: Money.fromDouble(150),
    subtotalAmount: Money.fromDouble(150),
    paymentMethod: 'card',
    createdAt: tNow,
    items: const [],
  );

  Future<void> pumpHero(
    WidgetTester tester,
    Widget child, {
    bool settle = true,
  }) async {
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
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group('SaleSuccessHero', () {
    testWidgets('shows change due for cash with positive change', (
      tester,
    ) async {
      await pumpHero(tester, SaleSuccessHero(sale: cashSale(), currency: '฿'));

      expect(find.byKey(const ValueKey('sale_success_hero')), findsOneWidget);
      expect(find.text('Payment complete'), findsOneWidget);
      expect(find.text('Receipt #R-100'), findsOneWidget);
      expect(find.text('Change due'), findsOneWidget);
    });

    testWidgets('hides change block when change is zero/null', (tester) async {
      await pumpHero(
        tester,
        SaleSuccessHero(
          sale: cashSale(change: Money.zero),
          currency: '฿',
        ),
      );

      expect(find.text('Change due'), findsNothing);
      expect(find.text('Payment complete'), findsOneWidget);
    });

    testWidgets('card sale has no change due label', (tester) async {
      await pumpHero(tester, SaleSuccessHero(sale: cardSale(), currency: '฿'));

      expect(find.text('Change due'), findsNothing);
      expect(find.text('Receipt #R-101'), findsOneWidget);
    });
  });

  group('SaleSuccessActions', () {
    testWidgets('Next sale is primary CTA and pops when pressed', (
      tester,
    ) async {
      var next = false;
      await pumpHero(
        tester,
        SaleSuccessActions(
          busy: false,
          onNextSale: () => next = true,
          onPrint: () {},
          onShare: () {},
        ),
      );

      expect(
        find.byKey(const ValueKey('sale_success_next_cta')),
        findsOneWidget,
      );
      expect(find.text('Next sale'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sale_success_next_cta')));
      await tester.pump();
      expect(next, isTrue);
    });

    testWidgets('disables actions when busy', (tester) async {
      // busy shows an indeterminate progress indicator — do not pumpAndSettle.
      await pumpHero(
        tester,
        SaleSuccessActions(
          busy: true,
          onNextSale: () {},
          onPrint: () {},
          onShare: () {},
        ),
        settle: false,
      );

      final nextBtn = tester.widget<FilledButton>(
        find.byKey(const ValueKey('sale_success_next_cta')),
      );
      expect(nextBtn.onPressed, isNull);
    });
  });
}
