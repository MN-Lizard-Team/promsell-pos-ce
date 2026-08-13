import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/utils/sale_add_to_cart.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

class _MockCartBloc extends MockBloc<CartEvent, CartState>
    implements CartBloc {}

void main() {
  late _MockCartBloc cartBloc;
  late MockSettingsCubit settingsCubit;
  final now = DateTime(2026, 1, 1);

  Product product({
    int stock = 5,
    bool track = true,
    bool withOptions = false,
  }) => Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(50),
    stock: stock,
    isActive: true,
    trackStock: track,
    createdAt: now,
    updatedAt: now,
    optionGroups: withOptions
        ? const [
            ProductOptionGroup(
              id: 'g1',
              productId: 'p1',
              name: 'Size',
              options: [],
            ),
          ]
        : const [],
  );

  setUp(() {
    cartBloc = _MockCartBloc();
    settingsCubit = MockSettingsCubit();
    when(() => cartBloc.state).thenReturn(const CartState());
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    registerFallbackValue(CartProductAdded(product()));
  });

  Future<SaleAddResult> pumpAndAdd(
    WidgetTester tester,
    Product p, {
    int qty = 1,
  }) async {
    late SaleAddResult result;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          return TextButton(
            onPressed: () async {
              result = await saleAddToCart(context, p, qty: qty);
            },
            child: const Text('add'),
          );
        },
      ),
      cartBloc: cartBloc,
      settingsCubit: settingsCubit,
    );
    await tester.tap(find.text('add'));
    await tester.pump();
    return result;
  }

  testWidgets('qty <= 0 is blocked', (tester) async {
    final r = await pumpAndAdd(tester, product(), qty: 0);
    expect(r, SaleAddResult.blocked);
    verifyNever(() => cartBloc.add(any()));
  });

  testWidgets('OOS without oversell is blockedOos', (tester) async {
    final r = await pumpAndAdd(tester, product(stock: 0));
    expect(r, SaleAddResult.blockedOos);
    verifyNever(() => cartBloc.add(any()));
  });

  testWidgets('simple product adds CartProductAdded', (tester) async {
    final r = await pumpAndAdd(tester, product(stock: 3), qty: 2);
    expect(r, SaleAddResult.added);
    verify(
      () => cartBloc.add(
        any(
          that: isA<CartProductAdded>()
              .having((e) => e.qty, 'qty', 2)
              .having((e) => e.allowOversell, 'over', false),
        ),
      ),
    ).called(1);
  });

  testWidgets('OOS allowed when oversell on', (tester) async {
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: Settings(stockConfig: StockConfig(allowOversell: true)),
      ),
    );
    final r = await pumpAndAdd(tester, product(stock: 0));
    expect(r, SaleAddResult.added);
    verify(() => cartBloc.add(any(that: isA<CartProductAdded>()))).called(1);
  });

  testWidgets('product with option groups opens sheet path', (tester) async {
    final r = await pumpAndAdd(tester, product(withOptions: true));
    expect(r, SaleAddResult.optionsOpened);
    // Sheet may or may not complete; no direct CartProductAdded until confirm.
    await tester.pump(); // settle sheet animation
  });

  testWidgets('saleAddToCartWithQtyDialog OOS blocked', (tester) async {
    late SaleAddResult result;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          return TextButton(
            onPressed: () async {
              result = await saleAddToCartWithQtyDialog(
                context,
                product(stock: 0),
                currentCartQty: 0,
              );
            },
            child: const Text('qty'),
          );
        },
      ),
      cartBloc: cartBloc,
      settingsCubit: settingsCubit,
    );
    await tester.tap(find.text('qty'));
    await tester.pump();
    expect(result, SaleAddResult.blockedOos);
  });

  testWidgets('saleAddToCartWithQtyDialog confirms qty', (tester) async {
    late SaleAddResult result;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          return TextButton(
            onPressed: () async {
              result = await saleAddToCartWithQtyDialog(
                context,
                product(stock: 10),
                currentCartQty: 0,
              );
            },
            child: const Text('qty'),
          );
        },
      ),
      cartBloc: cartBloc,
      settingsCubit: settingsCubit,
    );
    await tester.tap(find.text('qty'));
    await tester.pumpAndSettle();
    // Default text field is 1; tap Save (EN).
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(result, SaleAddResult.added);
    verify(() => cartBloc.add(any(that: isA<CartProductAdded>()))).called(1);
  });
}
