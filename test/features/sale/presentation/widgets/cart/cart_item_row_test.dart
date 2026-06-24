import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_row.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
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
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockCartBloc.state).thenReturn(const CartState());
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  group('CartItemRow', () {
    testWidgets('renders product info', (tester) async {
      await tester.pumpApp(
        CartItemRow(
          item: CartItem(product: product, qty: 2),
          currency: '฿',
        ),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('renders compact mode', (tester) async {
      await tester.pumpApp(
        CartItemRow(
          item: CartItem(product: product, qty: 2),
          currency: '฿',
          compact: true,
        ),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(CartItemRow), findsOneWidget);
    });

    testWidgets('renders selecting mode with checkbox', (tester) async {
      await tester.pumpApp(
        CartItemRow(
          item: CartItem(product: product, qty: 2),
          currency: '฿',
          isSelecting: true,
          isSelected: true,
          onTap: () {},
        ),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('renders with discount', (tester) async {
      await tester.pumpApp(
        CartItemRow(
          item: CartItem(
            product: product,
            qty: 2,
            discountType: 'PERCENT',
            discountValue: 10,
          ),
          currency: '฿',
        ),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('Coffee'), findsOneWidget);
    });
  });
}
