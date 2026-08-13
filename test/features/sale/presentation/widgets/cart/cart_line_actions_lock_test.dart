import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_actions.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockCheckoutBloc mockCheckoutBloc;

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockCheckoutBloc = MockCheckoutBloc();
    when(() => mockCartBloc.state).thenReturn(const CartState());
    when(() => mockCheckoutBloc.state).thenReturn(const CheckoutState());
  });

  group('CartLineActions.isPaymentLocked', () {
    testWidgets('false when idle and unlocked', (tester) async {
      late bool locked;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            locked = CartLineActions.isPaymentLocked(context);
            return const SizedBox();
          },
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
      );
      expect(locked, isFalse);
    });

    testWidgets('true when cart.paymentLocked', (tester) async {
      when(
        () => mockCartBloc.state,
      ).thenReturn(const CartState(paymentLocked: true));
      late bool locked;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            locked = CartLineActions.isPaymentLocked(context);
            return const SizedBox();
          },
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
      );
      expect(locked, isTrue);
    });

    testWidgets('true when checkout waitingPayment (parity guard)', (
      tester,
    ) async {
      when(
        () => mockCheckoutBloc.state,
      ).thenReturn(const CheckoutState(status: CheckoutStatus.waitingPayment));
      late bool locked;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            locked = CartLineActions.isPaymentLocked(context);
            return const SizedBox();
          },
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
      );
      expect(locked, isTrue);
    });

    testWidgets(
      'true when checkout processing (parity with DraftBillSwitchGuard)',
      (tester) async {
        when(
          () => mockCheckoutBloc.state,
        ).thenReturn(const CheckoutState(status: CheckoutStatus.processing));
        late bool locked;
        await tester.pumpApp(
          Builder(
            builder: (context) {
              locked = CartLineActions.isPaymentLocked(context);
              return const SizedBox();
            },
          ),
          cartBloc: mockCartBloc,
          checkoutBloc: mockCheckoutBloc,
        );
        expect(locked, isTrue);
      },
    );

    testWidgets('banner shows cartPaymentInProgress when locked', (
      tester,
    ) async {
      when(
        () => mockCartBloc.state,
      ).thenReturn(const CartState(paymentLocked: true));
      await tester.pumpApp(
        Builder(
          builder: (context) => CartLineActions.paymentLockBanner(context),
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
      );
      expect(find.textContaining('Payment'), findsWidgets);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });
}
