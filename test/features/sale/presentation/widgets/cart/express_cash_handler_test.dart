import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/express_cash_handler.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../../helpers/mocks.dart';

void main() {
  late MockCheckoutBloc mockCheckout;

  final tNow = DateTime(2025, 1, 1);
  final cart = CartState(
    items: [
      CartItem(
        product: Product(
          id: 'p1',
          name: 'A',
          price: Money.fromDouble(100),
          stock: 10,
          isActive: true,
          trackStock: true,
          createdAt: tNow,
          updatedAt: tNow,
        ),
        qty: 1,
      ),
    ],
  );

  setUp(() {
    mockCheckout = MockCheckoutBloc();
    registerFallbackValue(
      const CheckoutConfirmed(
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      ),
    );
    when(() => mockCheckout.add(any())).thenReturn(null);
    ExpressCashHandler.resetDebounceForTest();
  });

  Future<void> pumpPay(WidgetTester tester, CartState c) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<CheckoutBloc>.value(
          value: mockCheckout,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => ExpressCashHandler.pay(
                    context: context,
                    cart: c,
                    settings: const Settings(),
                  ),
                  child: const Text('pay'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('Wave P4: double tap within debounce fires once', (tester) async {
    await pumpPay(tester, cart);
    await tester.tap(find.text('pay'));
    await tester.tap(find.text('pay'));
    await tester.pump();
    verify(() => mockCheckout.add(any())).called(1);
  });

  testWidgets('Wave P4: skips when paymentLocked', (tester) async {
    await pumpPay(tester, cart.copyWith(paymentLocked: true));
    await tester.tap(find.text('pay'));
    await tester.pump();
    verifyNever(() => mockCheckout.add(any()));
  });

  testWidgets('Wave P4: skips empty cart', (tester) async {
    await pumpPay(tester, const CartState());
    await tester.tap(find.text('pay'));
    await tester.pump();
    verifyNever(() => mockCheckout.add(any()));
  });
}
