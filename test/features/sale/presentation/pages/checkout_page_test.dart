import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/checkout_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/cart_review_page.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSaleBloc mockSaleBloc;
  late MockSettingsCubit mockSettingsCubit;

  final testProduct = Product(
    id: 'p1',
    name: 'Water',
    price: 10.0,
    stock: 100,
    imageThumbnailPath: null,
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
        settings: AppSettings(showPreSalePreview: false),
      ),
    );
    if (!GetIt.I.isRegistered<ReceiptPdfService>()) {
      GetIt.I.registerSingleton<ReceiptPdfService>(ReceiptPdfService());
    }
  });

  Widget buildSubject() {
    return const CheckoutPage();
  }

  group('CheckoutPage', () {
    testWidgets('renders with cart action button', (tester) async {
      when(() => mockSaleBloc.state).thenReturn(const SaleState(items: []));

      await tester.pumpApp(
        buildSubject(),
        saleBloc: mockSaleBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('shows item count badge on cart button', (tester) async {
      final items = [CartItem(product: testProduct, qty: 2)];
      when(() => mockSaleBloc.state).thenReturn(SaleState(items: items));

      await tester.pumpApp(
        buildSubject(),
        saleBloc: mockSaleBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('navigates to CartReviewPage when cart button tapped', (
      tester,
    ) async {
      when(() => mockSaleBloc.state).thenReturn(const SaleState(items: []));

      await tester.pumpApp(
        buildSubject(),
        saleBloc: mockSaleBloc,
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(CartReviewPage), findsOneWidget);
    });

    testWidgets('hides badge when cart is empty', (tester) async {
      when(() => mockSaleBloc.state).thenReturn(const SaleState(items: []));

      await tester.pumpApp(
        buildSubject(),
        saleBloc: mockSaleBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('0'), findsNothing);
    });
  });
}
