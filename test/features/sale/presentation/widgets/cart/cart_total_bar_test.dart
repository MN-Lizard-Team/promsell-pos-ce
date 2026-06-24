import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_total_bar.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockCartBloc mockCartBloc;
  late MockCheckoutBloc mockCheckoutBloc;

  final tProduct = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    mockCartBloc = MockCartBloc();
    mockCheckoutBloc = MockCheckoutBloc();

    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockCartBloc.state).thenReturn(const CartState());
  });

  Future<void> pumpBar(
    WidgetTester tester,
    CartState state, {
    Settings? settings,
  }) async {
    when(() => mockSettingsCubit.state).thenReturn(
      SettingsState(
        status: SettingsStatus.loaded,
        settings: settings ?? const Settings(),
      ),
    );
    when(() => mockCartBloc.state).thenReturn(state);

    await tester.pumpApp(
      CartTotalBar(state: state, currency: '฿'),
      cartBloc: mockCartBloc,
      checkoutBloc: mockCheckoutBloc,
      settingsCubit: mockSettingsCubit,
    );
  }

  group('CartTotalBar', () {
    testWidgets('renders subtotal and total for non-empty cart', (
      tester,
    ) async {
      final state = CartState(items: [CartItem(product: tProduct, qty: 2)]);
      await pumpBar(tester, state);

      expect(find.byType(MoneyText), findsNWidgets(2));
    });

    testWidgets('shows item discount line when items have discounts', (
      tester,
    ) async {
      final state = CartState(
        items: [
          CartItem(
            product: tProduct,
            qty: 2,
            discountType: 'PERCENT',
            discountValue: 10,
          ),
        ],
      );
      await pumpBar(tester, state);

      expect(find.byType(MoneyText), findsNWidgets(3));
    });

    testWidgets('shows cart discount line when cart has discount', (
      tester,
    ) async {
      final state = CartState(
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
      );
      await pumpBar(tester, state);

      expect(find.byType(MoneyText), findsNWidgets(3));
    });

    testWidgets('shows checkout button', (tester) async {
      final state = CartState(items: [CartItem(product: tProduct, qty: 3)]);
      await pumpBar(tester, state);

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows cart discount button when enableCartDiscount is true', (
      tester,
    ) async {
      final state = CartState(items: [CartItem(product: tProduct, qty: 1)]);
      const settings = Settings(
        discountConfig: DiscountConfig(enableCartDiscount: true),
      );
      await pumpBar(tester, state, settings: settings);

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('does not show cart discount button when disabled', (
      tester,
    ) async {
      final state = CartState(items: [CartItem(product: tProduct, qty: 1)]);
      const settings = Settings(
        discountConfig: DiscountConfig(enableCartDiscount: false),
      );
      await pumpBar(tester, state, settings: settings);

      expect(find.byType(TextButton), findsNothing);
    });
  });
}
