import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_result_tile.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_product_search_page.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../helpers/mocks.dart';

class _FakeCartProductAdded extends Fake implements CartProductAdded {}

class _FakeProductSearchChanged extends Fake implements ProductSearchChanged {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockCartBloc mockCartBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockSettingsLocalDatasource mockSettingsLocal;
  late SearchHistoryCubit searchHistoryCubit;
  final sl = GetIt.instance;

  final tNow = DateTime(2025, 1, 15);

  final espresso = Product(
    id: 'prod-0001-0001-0001-000000000001',
    name: 'Espresso',
    sku: 'COF-001',
    barcode: '8850001',
    price: Money.fromDouble(60.0),
    stock: 100,
    isActive: true,
    trackStock: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final latte = Product(
    id: 'prod-0002-0002-0002-000000000002',
    name: 'Latte',
    sku: 'COF-002',
    barcode: '8850002',
    price: Money.fromDouble(70.0),
    stock: 50,
    isActive: true,
    trackStock: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final inactive = Product(
    id: 'prod-0003-0003-0003-000000000003',
    name: 'Retired Espresso',
    sku: 'COF-OLD',
    barcode: '8850099',
    price: Money.fromDouble(40.0),
    stock: 0,
    isActive: false,
    trackStock: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final oos = Product(
    id: 'prod-0004-0004-0004-000000000004',
    name: 'Sold Out Cake',
    sku: 'CAKE-00',
    barcode: '8850100',
    price: Money.fromDouble(90.0),
    stock: 0,
    isActive: true,
    trackStock: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final sharedBarcodeA = Product(
    id: 'prod-0005-0005-0005-000000000005',
    name: 'Shared A',
    barcode: '9990001',
    price: Money.fromDouble(10.0),
    stock: 5,
    isActive: true,
    trackStock: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final sharedBarcodeB = Product(
    id: 'prod-0006-0006-0006-000000000006',
    name: 'Shared B',
    barcode: '9990001',
    price: Money.fromDouble(12.0),
    stock: 5,
    isActive: true,
    trackStock: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final catalog = [
    espresso,
    latte,
    inactive,
    oos,
    sharedBarcodeA,
    sharedBarcodeB,
  ];

  Future<void> pumpSearchPage(
    WidgetTester tester, {
    Settings? settings,
    CartState? cartState,
    bool pushOntoStack = false,
  }) async {
    when(() => mockSettingsCubit.state).thenReturn(
      SettingsState(
        status: SettingsStatus.loaded,
        settings: settings ?? const Settings(),
      ),
    );
    when(
      () => mockCartBloc.state,
    ).thenReturn(cartState ?? const CartState(items: []));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: mockProductBloc),
          BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
          BlocProvider<SearchHistoryCubit>.value(value: searchHistoryCubit),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: pushOntoStack
              ? Builder(
                  builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SaleProductSearchPage(),
                        ),
                      );
                    });
                    return const Scaffold(body: Text('sale-search-host'));
                  },
                )
              : const SaleProductSearchPage(),
        ),
      ),
    );
    await tester.pump();
    if (pushOntoStack) {
      await tester.pumpAndSettle();
    }
  }

  setUpAll(() {
    registerFallbackValue(_FakeCartProductAdded());
    registerFallbackValue(_FakeProductSearchChanged());
  });

  setUp(() async {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockCartBloc = MockCartBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockSettingsLocal = MockSettingsLocalDatasource();

    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    when(
      () => mockSettingsLocal.getString(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockSettingsLocal.setString(any(), any()),
    ).thenAnswer((_) async {});

    searchHistoryCubit = SearchHistoryCubit(
      mockSettingsLocal,
      'sale_search_history',
    );
    await searchHistoryCubit.load();

    if (sl.isRegistered<SettingsLocalDatasource>()) {
      sl.unregister<SettingsLocalDatasource>();
    }
    sl.registerSingleton<SettingsLocalDatasource>(mockSettingsLocal);
  });

  tearDown(() async {
    await searchHistoryCubit.close();
    await sl.reset();
  });

  group('SaleProductSearchPage', () {
    testWidgets('shows empty state when query is empty and no history', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(tester);

      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(find.byType(SearchResultTile), findsNothing);
    });

    testWidgets(
      'history chip applies query locally (does not touch ProductBloc search)',
      (tester) async {
        when(() => mockProductBloc.state).thenReturn(
          ProductState(status: ProductStatus.success, products: catalog),
        );
        when(
          () => mockSettingsLocal.getString('sale_search_history'),
        ).thenAnswer((_) async => '["Latte"]');
        await searchHistoryCubit.load();

        await pumpSearchPage(tester);
        await tester.pumpAndSettle();

        expect(find.text('Latte'), findsOneWidget);
        clearInteractions(mockProductBloc);
        await tester.tap(find.text('Latte'));
        await tester.pump();

        // Sale search query is local — must not filter shared ProductBloc.
        verifyNever(
          () => mockProductBloc.add(any(that: isA<ProductSearchChanged>())),
        );
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.text, 'Latte');
        expect(find.byType(SearchResultTile), findsWidgets);
      },
    );

    testWidgets(
      'type shows SearchResultTile and never writes ProductSearchChanged',
      (tester) async {
        when(() => mockProductBloc.state).thenReturn(
          ProductState(status: ProductStatus.success, products: catalog),
        );

        await pumpSearchPage(tester);
        clearInteractions(mockProductBloc);

        await tester.enterText(find.byType(TextField), 'esp');
        await tester.pump();

        verifyNever(
          () => mockProductBloc.add(any(that: isA<ProductSearchChanged>())),
        );

        expect(find.byType(SearchResultTile), findsWidgets);
        final tile = tester.widget<SearchResultTile>(
          find.byType(SearchResultTile).first,
        );
        expect(tile.product.name, 'Espresso');
        expect(tile.showAddAffordance, isTrue);
      },
    );

    testWidgets('inactive-only matches show empty state', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'Retired');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(find.byType(SearchResultTile), findsNothing);
    });

    testWidgets('tap tile dispatches CartProductAdded and stays on page', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'esp');
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.byType(SearchResultTile).first);
      await tester.pump();

      verify(
        () => mockCartBloc.add(
          any(
            that: isA<CartProductAdded>().having(
              (e) => e.product.id,
              'product.id',
              espresso.id,
            ),
          ),
        ),
      ).called(1);
      expect(find.byType(SaleProductSearchPage), findsOneWidget);
    });

    testWidgets('OOS product with oversell off does not add', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(
        tester,
        settings: const Settings().copyWith(allowOversell: false),
      );

      await tester.enterText(find.byType(TextField), 'Sold Out');
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.byType(SearchResultTile).first);
      await tester.pumpAndSettle();

      verifyNever(() => mockCartBloc.add(any(that: isA<CartProductAdded>())));
      expect(find.textContaining('Out of stock'), findsWidgets);
    });

    testWidgets('submit exact unique barcode adds product', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), '8850001');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      verify(
        () => mockCartBloc.add(
          any(
            that: isA<CartProductAdded>().having(
              (e) => e.product.barcode,
              'barcode',
              '8850001',
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('submit ambiguous barcode shows snack and does not add', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), '9990001');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      verifyNever(() => mockCartBloc.add(any(that: isA<CartProductAdded>())));
      expect(find.textContaining('share this barcode'), findsOneWidget);
    });

    testWidgets(
      'clear button clears field and shows empty/history (local only)',
      (tester) async {
        when(() => mockProductBloc.state).thenReturn(
          ProductState(status: ProductStatus.success, products: catalog),
        );

        await pumpSearchPage(tester);

        await tester.enterText(find.byType(TextField), 'esp');
        await tester.pump();
        clearInteractions(mockProductBloc);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        verifyNever(
          () => mockProductBloc.add(any(that: isA<ProductSearchChanged>())),
        );
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.text, isEmpty);
      },
    );

    testWidgets('scan icon visible when barcodeScanEnabled', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(
        tester,
        settings: const Settings().copyWith(barcodeScanEnabled: true),
      );

      expect(find.byKey(const ValueKey('sale-search-scan')), findsOneWidget);
    });

    testWidgets('scan icon hidden when barcodeScanEnabled is false', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(
        tester,
        settings: const Settings().copyWith(barcodeScanEnabled: false),
      );

      expect(find.byKey(const ValueKey('sale-search-scan')), findsNothing);
    });

    testWidgets('cart error barcodeNotFound shows create action snack', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      final cartStream = StreamController<CartState>.broadcast();
      addTearDown(cartStream.close);
      whenListen(
        mockCartBloc,
        cartStream.stream,
        initialState: const CartState(items: []),
      );

      await pumpSearchPage(tester);
      await tester.pump();

      const failed = CartState(
        items: [],
        errorMessage: 'barcodeNotFound',
        lastFailedBarcode: '000111',
        errorNonce: 1,
      );
      when(() => mockCartBloc.state).thenReturn(failed);
      cartStream.add(failed);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No product found with this barcode'),
        findsOneWidget,
      );
      expect(find.textContaining('Create product'), findsOneWidget);
    });

    testWidgets('shows cart qty badge on result tile when N>0', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(
        tester,
        cartState: CartState(items: [CartItem(product: espresso, qty: 3)]),
      );

      await tester.enterText(find.byType(TextField), 'esp');
      await tester.pump(const Duration(milliseconds: 350));

      final tile = tester.widget<SearchResultTile>(
        find.byType(SearchResultTile).first,
      );
      expect(tile.cartQty, 3);
      expect(find.text('×3'), findsOneWidget);
    });

    testWidgets('back button pops search route and clears ProductBloc query', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: catalog),
      );

      await pumpSearchPage(tester, pushOntoStack: true);

      expect(find.byType(SaleProductSearchPage), findsOneWidget);
      expect(find.text('sale-search-host'), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(SaleProductSearchPage), findsNothing);
      expect(find.text('sale-search-host'), findsOneWidget);
      verify(
        () => mockProductBloc.add(const ProductSearchChanged('')),
      ).called(1);
    });
  });
}
