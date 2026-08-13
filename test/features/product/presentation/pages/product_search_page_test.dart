import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_result_tile.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_sku.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_preview_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_search_page.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../helpers/mocks.dart';

class _FakeProductSearchChanged extends Fake implements ProductSearchChanged {}

class _MockGenerateBarcode extends Mock implements GenerateBarcode {}

class _MockGenerateSku extends Mock implements GenerateSku {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockSettingsLocalDatasource mockSettingsLocal;
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
    createdAt: tNow,
    updatedAt: tNow,
  );

  final greenTea = Product(
    id: 'prod-0003-0003-0003-000000000003',
    name: 'Green Tea',
    sku: 'TEA-001',
    barcode: '8850003',
    price: Money.fromDouble(45.0),
    stock: 80,
    isActive: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final inactive = Product(
    id: 'prod-0004-0004-0004-000000000004',
    name: 'Retired Espresso',
    sku: 'COF-OLD',
    barcode: '8850099',
    price: Money.fromDouble(40.0),
    stock: 0,
    isActive: false,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final sharedA = Product(
    id: 'prod-0005-0005-0005-000000000005',
    name: 'Shared A',
    barcode: '9990001',
    price: Money.fromDouble(10.0),
    stock: 5,
    isActive: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final sharedB = Product(
    id: 'prod-0006-0006-0006-000000000006',
    name: 'Shared B',
    barcode: '9990001',
    price: Money.fromDouble(12.0),
    stock: 5,
    isActive: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  final testProducts = [espresso, latte, greenTea, inactive, sharedA, sharedB];

  Future<void> pumpSearchPage(WidgetTester tester, {Settings? settings}) async {
    when(() => mockSettingsCubit.state).thenReturn(
      SettingsState(
        status: SettingsStatus.loaded,
        settings: settings ?? const Settings(),
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: mockProductBloc),
          BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProductSearchPage(),
        ),
      ),
    );
    await tester.pump();
  }

  setUpAll(() {
    registerFallbackValue(_FakeProductSearchChanged());
  });

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockSettingsLocal = MockSettingsLocalDatasource();

    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    when(
      () => mockSettingsLocal.getString(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockSettingsLocal.setString(any(), any()),
    ).thenAnswer((_) async {});

    sl.registerSingleton<ProductBloc>(mockProductBloc);
    sl.registerSingleton<CategoryBloc>(mockCategoryBloc);
    if (sl.isRegistered<SettingsLocalDatasource>()) {
      sl.unregister<SettingsLocalDatasource>();
    }
    sl.registerSingleton<SettingsLocalDatasource>(mockSettingsLocal);

    if (sl.isRegistered<GenerateBarcode>()) {
      sl.unregister<GenerateBarcode>();
    }
    sl.registerSingleton<GenerateBarcode>(_MockGenerateBarcode());
    if (sl.isRegistered<GenerateSku>()) {
      sl.unregister<GenerateSku>();
    }
    sl.registerSingleton<GenerateSku>(_MockGenerateSku());
    if (sl.isRegistered<WatchInventoryLogs>()) {
      sl.unregister<WatchInventoryLogs>();
    }
    final watchLogs = MockWatchInventoryLogs();
    when(
      () => watchLogs(productId: any(named: 'productId')),
    ).thenAnswer((_) => const Stream.empty());
    when(() => watchLogs()).thenAnswer((_) => const Stream.empty());
    sl.registerSingleton<WatchInventoryLogs>(watchLogs);
  });

  tearDown(() => sl.reset());

  group('ProductSearchPage', () {
    testWidgets('shows empty state when query is empty and no history', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(find.byType(SearchResultTile), findsNothing);
    });

    testWidgets('shows filtered results when query matches', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(
          status: ProductStatus.success,
          products: testProducts,
          searchQuery: 'esp',
        ),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'esp');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(SearchResultTile), findsWidgets);
      final tile = tester.widget<SearchResultTile>(
        find.byType(SearchResultTile).first,
      );
      expect(tile.product.name, 'Espresso');
    });

    testWidgets('shows empty state when query has no matches', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(
          status: ProductStatus.success,
          products: testProducts,
          searchQuery: 'xyz',
        ),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(SearchEmptyState), findsOneWidget);
      expect(find.byType(SearchResultTile), findsNothing);
    });

    testWidgets(
      'shows recent searches when focused with empty query and history',
      (tester) async {
        when(() => mockProductBloc.state).thenReturn(
          ProductState(status: ProductStatus.success, products: testProducts),
        );
        when(
          () => mockSettingsLocal.getString('product_search_history'),
        ).thenAnswer((_) async => '["Latte","Espresso"]');

        await pumpSearchPage(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextField));
        await tester.pump();

        expect(find.text('Latte'), findsOneWidget);
        expect(find.text('Espresso'), findsOneWidget);
      },
    );

    testWidgets('tapping a recent search fills the search field', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );
      when(
        () => mockSettingsLocal.getString('product_search_history'),
      ).thenAnswer((_) async => '["Latte"]');

      await pumpSearchPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text('Latte'));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Latte');
    });

    testWidgets('has a back button in app bar', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has a search text field with hint text', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('includes inactive products in results with label', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'Retired');
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(SearchResultTile), findsOneWidget);
      expect(find.textContaining('Inactive'), findsWidgets);
    });

    testWidgets('tap result opens ProductPreviewPage', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'esp');
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.byType(SearchResultTile).first);
      await tester.pumpAndSettle();

      expect(find.byType(ProductPreviewPage), findsOneWidget);
    });

    testWidgets('submit exact unique barcode opens preview', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), '8850001');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.byType(ProductPreviewPage), findsOneWidget);
    });

    testWidgets(
      'submit ambiguous barcode shows snack without opening preview',
      (tester) async {
        when(() => mockProductBloc.state).thenReturn(
          ProductState(status: ProductStatus.success, products: testProducts),
        );

        await pumpSearchPage(tester);

        await tester.enterText(find.byType(TextField), '9990001');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(find.byType(ProductPreviewPage), findsNothing);
        expect(find.textContaining('share this barcode'), findsOneWidget);
      },
    );

    testWidgets('scan icon visible when barcodeScanEnabled', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(
        tester,
        settings: const Settings().copyWith(barcodeScanEnabled: true),
      );
      expect(find.byKey(const ValueKey('product-search-scan')), findsOneWidget);
    });

    testWidgets('scan icon hidden when barcodeScanEnabled is false', (
      tester,
    ) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(
        tester,
        settings: const Settings(
          barcodeConfig: BarcodeConfig(scanEnabled: false),
        ),
      );
      expect(find.byKey(const ValueKey('product-search-scan')), findsNothing);
    });

    testWidgets('clear dispatches ProductSearchChanged empty', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'esp');
      await tester.pump(const Duration(milliseconds: 350));
      clearInteractions(mockProductBloc);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(
        () => mockProductBloc.add(const ProductSearchChanged('')),
      ).called(1);
    });

    testWidgets('partial type then pop does not write history', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: testProducts),
      );

      await pumpSearchPage(tester);

      await tester.enterText(find.byType(TextField), 'es');
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      verifyNever(
        () => mockSettingsLocal.setString('product_search_history', any()),
      );
    });
  });
}
