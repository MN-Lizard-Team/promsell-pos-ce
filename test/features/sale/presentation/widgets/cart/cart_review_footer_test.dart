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
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_footer.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockDraftBloc mockDraftBloc;
  late MockCheckoutBloc mockCheckoutBloc;

  final product = Product(
    id: 'p1',
    name: 'Water',
    price: Money.fromDouble(50),
    stock: 10,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockDraftBloc = MockDraftBloc();
    mockCheckoutBloc = MockCheckoutBloc();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockDraftBloc.state).thenReturn(const DraftState());
    when(() => mockCheckoutBloc.state).thenReturn(const CheckoutState());
  });

  Future<void> pumpFooter(WidgetTester tester, CartState cart) async {
    when(() => mockCartBloc.state).thenReturn(cart);
    await tester.pumpWidget(
      // Theme extension for park/pay tokens; l10n via pumpApp.
      const SizedBox.shrink(),
    );
    await tester.pumpApp(
      Theme(
        data: ThemeData(extensions: const [PosThemeExtension.light]),
        child: const CartReviewFooter(),
      ),
      cartBloc: mockCartBloc,
      draftBloc: mockDraftBloc,
      checkoutBloc: mockCheckoutBloc,
      settingsCubit: mockSettingsCubit,
    );
  }

  testWidgets('shows amount due and park/pay keys with lines', (tester) async {
    final cart = CartState(items: [CartItem(product: product, qty: 2)]);
    await pumpFooter(tester, cart);

    expect(find.textContaining('Amount due'), findsOneWidget);
    // 2 × 50 = 100 payable under default settings.
    expect(find.textContaining('100'), findsWidgets);
    expect(find.byKey(const ValueKey('sale_cart_park_cta')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sale_cart_checkout_cta')),
      findsOneWidget,
    );
  });

  testWidgets('empty cart still builds footer with disabled CTAs', (
    tester,
  ) async {
    await pumpFooter(tester, const CartState());
    expect(find.byKey(const ValueKey('sale_cart_park_cta')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sale_cart_checkout_cta')),
      findsOneWidget,
    );
    final park = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('sale_cart_park_cta')),
    );
    expect(park.onPressed, isNull);
  });
}
