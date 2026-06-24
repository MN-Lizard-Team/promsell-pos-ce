import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_product_card.dart';
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

  group('SaleProductCard', () {
    testWidgets('renders product name and price', (tester) async {
      await tester.pumpApp(
        SaleProductCard(product: product, currency: '฿'),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('renders out of stock product', (tester) async {
      final outOfStock = product.copyWith(stock: 0);
      await tester.pumpApp(
        SaleProductCard(product: outOfStock, currency: '฿'),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(Opacity), findsOneWidget);
    });
  });
}
