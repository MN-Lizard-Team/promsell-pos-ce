import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/payment_sheet_redesign.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment_widgets.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockCheckoutBloc mockCheckoutBloc;
  late MockSettingsCubit mockSettingsCubit;

  final testProduct = Product(
    id: 'prod-0001-0001-0001-000000000001',
    name: 'Water',
    price: 10.0,
    stock: 100,
    imageThumbnailPath: null,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockCheckoutBloc = MockCheckoutBloc();
    when(() => mockCheckoutBloc.state).thenReturn(const CheckoutState());
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    if (!GetIt.I.isRegistered<ReceiptPdfService>()) {
      GetIt.I.registerSingleton<ReceiptPdfService>(ReceiptPdfService());
    }
  });

  setUpAll(() {
    registerFallbackValue(
      const CheckoutConfirmed(
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        amountReceived: 0,
        changeAmount: 0,
      ),
    );
  });

  group('PaymentSheet', () {
    testWidgets('renders with cart total', (tester) async {
      when(
        () => mockCartBloc.state,
      ).thenReturn(CartState(items: [CartItem(product: testProduct, qty: 3)]));

      await tester.pumpApp(
        const PaymentSheet(),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(PaymentSheet), findsOneWidget);
    });

    testWidgets('shows payment method chips', (tester) async {
      when(
        () => mockCartBloc.state,
      ).thenReturn(CartState(items: [CartItem(product: testProduct, qty: 1)]));

      await tester.pumpApp(
        const PaymentSheet(),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(PaymentMethodCard), findsNWidgets(3));
    });

    testWidgets(
      'UI-BUG-8 regression: shows insufficient cash message when amount < total',
      (tester) async {
        when(() => mockCartBloc.state).thenReturn(
          CartState(items: [CartItem(product: testProduct, qty: 3)]),
        );

        await tester.pumpApp(
          const PaymentSheet(),
          cartBloc: mockCartBloc,
          checkoutBloc: mockCheckoutBloc,
          settingsCubit: mockSettingsCubit,
        );

        // Enter insufficient amount
        final textField = find.byType(TextFormField).first;
        await tester.enterText(textField, '10');
        await tester.pumpAndSettle();

        expect(find.textContaining('Insufficient'), findsOneWidget);
      },
    );
  });
}
