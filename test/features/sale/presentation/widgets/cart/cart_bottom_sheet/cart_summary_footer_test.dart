import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_summary_footer.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../../helpers/mocks.dart';
import '../../../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockCheckoutBloc mockCheckoutBloc;
  late MockSettingsCubit mockSettingsCubit;

  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockCheckoutBloc = MockCheckoutBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockCartBloc.state).thenReturn(const CartState());
    when(() => mockCheckoutBloc.state).thenReturn(const CheckoutState());
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  group('CartSummaryFooter', () {
    testWidgets('renders empty cart as SizedBox', (tester) async {
      await tester.pumpApp(
        CartSummaryFooter(
          bottomInset: 16,
          currency: '฿',
          settings: const Settings(),
          onCheckout: () {},
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders subtotal and total for non-empty cart', (
      tester,
    ) async {
      when(
        () => mockCartBloc.state,
      ).thenReturn(CartState(items: [CartItem(product: product, qty: 2)]));
      await tester.pumpApp(
        CartSummaryFooter(
          bottomInset: 16,
          currency: '฿',
          settings: const Settings(),
          onCheckout: () {},
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(MoneyText), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders item discount row', (tester) async {
      when(() => mockCartBloc.state).thenReturn(
        CartState(
          items: [
            CartItem(
              product: product,
              qty: 2,
              discountType: 'PERCENT',
              discountValue: 10,
            ),
          ],
        ),
      );
      await tester.pumpApp(
        CartSummaryFooter(
          bottomInset: 16,
          currency: '฿',
          settings: const Settings(),
          onCheckout: () {},
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(MoneyText), findsNWidgets(3));
    });

    testWidgets('shows cart discount button when enabled', (tester) async {
      when(
        () => mockCartBloc.state,
      ).thenReturn(CartState(items: [CartItem(product: product, qty: 1)]));
      const settings = Settings(
        discountConfig: DiscountConfig(enableCartDiscount: true),
      );
      await tester.pumpApp(
        CartSummaryFooter(
          bottomInset: 16,
          currency: '฿',
          settings: settings,
          onCheckout: () {},
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
