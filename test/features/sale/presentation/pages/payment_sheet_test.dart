import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/payment_sheet_redesign.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSaleBloc mockSaleBloc;
  late MockSettingsCubit mockSettingsCubit;

  final testProduct = Product(
    id: 'prod-0001-0001-0001-000000000001',
    name: 'Water',
    price: 10.0,
    stock: 100,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockSaleBloc = MockSaleBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: AppSettings(),
      ),
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const SaleConfirmed(
        paymentMethod: 'cash',
        amountReceived: 0,
        changeAmount: 0,
      ),
    );
  });

  group('PaymentSheet', () {
    testWidgets('renders with cart total', (tester) async {
      when(
        () => mockSaleBloc.state,
      ).thenReturn(SaleState(items: [CartItem(product: testProduct, qty: 3)]));

      await tester.pumpApp(
        const PaymentSheet(total: 30.0),
        saleBloc: mockSaleBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(PaymentSheet), findsOneWidget);
    });

    testWidgets('shows payment method chips', (tester) async {
      when(
        () => mockSaleBloc.state,
      ).thenReturn(SaleState(items: [CartItem(product: testProduct, qty: 1)]));

      await tester.pumpApp(
        const PaymentSheet(total: 10.0),
        saleBloc: mockSaleBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets(
      'UI-BUG-8 regression: shows insufficient cash message when amount < total',
      (tester) async {
        when(() => mockSaleBloc.state).thenReturn(
          SaleState(items: [CartItem(product: testProduct, qty: 3)]),
        );

        await tester.pumpApp(
          const PaymentSheet(total: 30.0),
          saleBloc: mockSaleBloc,
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
