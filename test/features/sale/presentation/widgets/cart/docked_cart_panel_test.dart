import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/docked_cart_panel.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockCheckoutBloc mockCheckoutBloc;
  late MockDraftBloc mockDraftBloc;
  late MockSettingsCubit mockSettingsCubit;

  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(40),
    stock: 5,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockCheckoutBloc = MockCheckoutBloc();
    mockDraftBloc = MockDraftBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockCheckoutBloc.state).thenReturn(const CheckoutState());
    when(() => mockDraftBloc.state).thenReturn(
      const DraftState(openBillCount: 2, activeDraftName: 'Table 1'),
    );
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  testWidgets('empty dock shows empty chrome and footer', (tester) async {
    when(() => mockCartBloc.state).thenReturn(const CartState());
    await tester.pumpApp(
      Theme(
        data: ThemeData(extensions: const [PosThemeExtension.light]),
        child: const SizedBox(
          width: 380,
          height: 640,
          child: DockedCartPanel(),
        ),
      ),
      cartBloc: mockCartBloc,
      checkoutBloc: mockCheckoutBloc,
      draftBloc: mockDraftBloc,
      settingsCubit: mockSettingsCubit,
    );
    expect(find.byType(DockedCartPanel), findsOneWidget);
    expect(find.byKey(const ValueKey('sale_cart_park_cta')), findsOneWidget);
  });

  testWidgets(
    'with lines renders CartItemCard and lock freezes when processing',
    (tester) async {
      when(
        () => mockCartBloc.state,
      ).thenReturn(CartState(items: [CartItem(product: product, qty: 1)]));
      when(
        () => mockCheckoutBloc.state,
      ).thenReturn(const CheckoutState(status: CheckoutStatus.processing));
      await tester.pumpApp(
        Theme(
          data: ThemeData(extensions: const [PosThemeExtension.light]),
          child: const SizedBox(
            width: 380,
            height: 640,
            child: DockedCartPanel(),
          ),
        ),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        draftBloc: mockDraftBloc,
        settingsCubit: mockSettingsCubit,
      );
      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.textContaining('Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    },
  );
}
