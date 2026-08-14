import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_sku.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/category_field.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_hero_image.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'dart:convert';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

/// Helper: pump the form and settle.
Future<void> _pumpForm(
  WidgetTester tester,
  Widget page,
  MockProductBloc productBloc,
  MockCategoryBloc categoryBloc,
  MockSettingsCubit settingsCubit,
  ProductFormCubit formCubit,
) async {
  await tester.pumpApp(
    page,
    productBloc: productBloc,
    categoryBloc: categoryBloc,
    settingsCubit: settingsCubit,
    productFormCubit: formCubit,
  );
  await tester.pumpAndSettle();
}

/// Helper: switch form tab (0=Info/Product, 1=Price, 2=Stock, 3=Codes).
Future<void> _goToFormTab(WidgetTester tester, int index) async {
  final labels = ['Info', 'Price', 'Stock', 'Codes'];
  final tab = find.text(labels[index]);
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

/// Helper: find Track Stock toggle among status toggles.
Finder _trackStockToggle() {
  return find.ancestor(
    of: find.text('Track Stock'),
    matching: find.byType(ModernToggleCard),
  );
}

Finder _saveButton() => find.byKey(const ValueKey('product-form-save'));

Future<void> _openDeleteMenu(WidgetTester tester) async {
  // DetailHeader more button (same pattern as Product Preview).
  await tester.tap(find.byIcon(TablerIcons.dotsVertical));
  await tester.pumpAndSettle();
}

class _MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

class _MockGenerateBarcode extends Mock implements GenerateBarcode {}

class _MockGenerateSku extends Mock implements GenerateSku {}

class _MockAppLockService extends Mock implements AppLockService {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsCubit mockSettingsCubit;
  late _MockSettingsLocalDatasource mockSettingsDs;
  late ProductFormCubit productFormCubit;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockSettingsDs = _MockSettingsLocalDatasource();
    when(() => mockSettingsDs.getString(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDs.setString(any(), any())).thenAnswer((_) async {});
    productFormCubit = ProductFormCubit(
      mockSettingsDs,
      _MockGenerateBarcode(),
      _MockGenerateSku(),
    );

    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    if (!GetIt.I.isRegistered<ProductImageService>()) {
      GetIt.I.registerSingleton<ProductImageService>(MockProductImageService());
    }
    if (!GetIt.I.isRegistered<GenerateBarcode>()) {
      GetIt.I.registerSingleton<GenerateBarcode>(_MockGenerateBarcode());
    }
    if (!GetIt.I.isRegistered<GenerateSku>()) {
      GetIt.I.registerSingleton<GenerateSku>(_MockGenerateSku());
    }
    // V092-B.1: form submit calls ensureAppUnlocked → sl<AppLockService>.
    // Register a mock with lock disabled so submit proceeds without PIN.
    final mockAppLock = _MockAppLockService();
    when(() => mockAppLock.isEnabled()).thenAnswer((_) async => false);
    if (!GetIt.I.isRegistered<AppLockService>()) {
      GetIt.I.registerSingleton<AppLockService>(mockAppLock);
    }
    when(
      () => mockProductBloc.state,
    ).thenReturn(const ProductState(status: ProductStatus.success));
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  tearDown(() {
    GetIt.I.reset();
    productFormCubit.close();
  });

  setUpAll(() {
    registerFallbackValue(const ProductAdded(name: '', price: 0, stock: 0));
    registerFallbackValue(
      ProductUpdated(
        Product(
          id: 'fallback',
          name: '',
          price: Money.zero,
          stock: 0,
          imageThumbnailPath: null,
          isActive: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ),
    );
  });

  group('ProductFormPage (add mode)', () {
    testWidgets('renders form with tabs, info fields and sticky bar', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.byType(StickyActionBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(CategoryField), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      expect(find.text('Codes'), findsOneWidget);
    });

    testWidgets('shows Add Product title in header', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.text('Add Product'), findsWidgets);
    });

    testWidgets('does not show DangerZoneCard in add mode', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.byType(StickyActionBar), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('shows ProductHeroImage and CategoryField', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.byType(ProductHeroImage), findsWidgets);
      expect(find.byType(CategoryField), findsOneWidget);
    });

    testWidgets('extra section collapsed by default hides supplier field', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.text('Supplier'), findsNothing);
    });

    testWidgets('pricing tab shows retail price and average cost', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 1);
      expect(find.text('Selling Price'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Markup from Cost'), findsOneWidget);

      await _goToFormTab(tester, 3);
      expect(find.text('SKU'), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await tester.tap(_saveButton());
      await tester.pumpAndSettle();

      expect(find.text('Please enter product name'), findsOneWidget);
    });

    testWidgets('dispatches ProductAdded on valid submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      final nameField = find.byKey(const ValueKey('product-form-name'));
      await tester.enterText(nameField, 'Water');

      await _goToFormTab(tester, 1);
      final priceField = find.byKey(const ValueKey('product-form-price'));
      await tester.enterText(priceField, '10.00');

      await tester.tap(_saveButton());
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockProductBloc.add(any(that: isA<ProductAdded>())),
      ).called(1);
    });

    testWidgets('shows error when price is empty', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      final nameField = find.byKey(const ValueKey('product-form-name'));
      await tester.enterText(nameField, 'Test');

      await tester.tap(_saveButton());
      await tester.pumpAndSettle();

      // Jumps to Price tab so the error is visible.
      expect(find.text('Please enter price'), findsOneWidget);
      expect(find.text('Selling Price'), findsOneWidget);
    });

    testWidgets('shows error when barcode has special characters', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await tester.enterText(
        find.byKey(const ValueKey('product-form-name')),
        'Test',
      );
      await _goToFormTab(tester, 1);
      await tester.enterText(
        find.byKey(const ValueKey('product-form-price')),
        '10.00',
      );

      await _goToFormTab(tester, 3);
      final barcodeField = find.byKey(const ValueKey('product-form-barcode'));
      await tester.ensureVisible(barcodeField);
      await tester.enterText(barcodeField, 'ABC-123!');

      final saveBtn = _saveButton();
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Barcode must contain only letters and numbers (no spaces, hyphens, or special characters)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows live barcode strip and copy when barcode entered', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 3);
      expect(
        find.byKey(const ValueKey('product-form-barcode-live-strip')),
        findsNothing,
      );
      expect(
        find.text('Preview appears when you enter or generate a barcode'),
        findsOneWidget,
      );

      final barcodeField = find.byKey(const ValueKey('product-form-barcode'));
      await tester.ensureVisible(barcodeField);
      await tester.enterText(barcodeField, '1234567890123');
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('product-form-barcode-live-strip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('product-form-barcode-copy')),
        findsOneWidget,
      );
      expect(find.text('EAN-13'), findsOneWidget);
    });

    testWidgets('stock stepper increments when + tapped', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 2);
      expect(find.byType(StockStepper), findsOneWidget);
      final stepper = find.byType(StockStepper);
      await tester.ensureVisible(stepper);
      final incBtn = find.descendant(
        of: stepper,
        matching: find.byIcon(Icons.add),
      );
      await tester.tap(incBtn);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets);
    });
  });

  group('ProductFormPage responsive layout', () {
    testWidgets('renders flattened form on a compact viewport', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(500, 900));
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.byType(StickyActionBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders flattened form on a medium viewport', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(700, 900));
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.byType(StickyActionBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders flattened form on a wide viewport', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(900, 900));
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );
      expect(find.byType(StickyActionBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ProductFormPage (edit mode)', () {
    final existingProduct = Product(
      id: 'prod-0001-0001-0001-000000000001',
      name: 'Water',
      price: Money.fromDouble(10.0),
      stock: 100,
      categoryId: 'drinks-001',
      imageThumbnailPath: null,
      isActive: true,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    testWidgets('pre-fills fields with existing product', (tester) async {
      await _pumpForm(
        tester,
        ProductFormPage(product: existingProduct),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.text('Water'), findsWidgets);
      await _goToFormTab(tester, 1);
      expect(find.text('10.00'), findsWidgets);
      expect(find.byIcon(TablerIcons.dotsVertical), findsOneWidget);
    });

    testWidgets('pre-fills all text fields with existing product values', (
      tester,
    ) async {
      final full = Product(
        id: 'prod-full-0001-0001-0001-000000000001',
        name: 'Espresso',
        sku: 'SKU-001',
        barcode: '8851234567890',
        price: Money.fromDouble(55.0),
        cost: Money.fromDouble(30.0),
        stock: 42,
        description: 'Single origin beans',
        brand: 'Northern Roasters',
        unit: 'cup',
        supplier: 'Bean Co.',
        isActive: true,
        trackStock: true,
        imageThumbnailPath: null,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      await _pumpForm(
        tester,
        ProductFormPage(product: full),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      // Info tab: name + description + brand.
      expect(find.text('Espresso'), findsWidgets);
      expect(find.text('Single origin beans'), findsWidgets);
      expect(find.text('Northern Roasters'), findsWidgets);

      // Price tab: price + cost.
      await _goToFormTab(tester, 1);
      expect(find.text('55.00'), findsWidgets);
      expect(find.text('30.00'), findsWidgets);

      // Stock tab: unit field (stock is rendered via StockStepper, not plain text).
      await _goToFormTab(tester, 2);
      expect(find.text('cup'), findsWidgets);

      // Codes tab: sku + barcode + supplier.
      await _goToFormTab(tester, 3);
      expect(find.text('SKU-001'), findsWidgets);
      expect(find.text('8851234567890'), findsWidgets);
      expect(find.text('Bean Co.'), findsWidgets);
    });

    testWidgets('pre-fills option groups with existing product values', (
      tester,
    ) async {
      final withOptions = Product(
        id: 'prod-opt-0001-0001-0001-000000000001',
        name: 'Coffee',
        price: Money.fromDouble(40.0),
        stock: 10,
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        optionGroups: const [
          ProductOptionGroup(
            id: 'grp-1',
            productId: 'prod-opt-0001-0001-0001-000000000001',
            name: 'Size',
            options: [
              ProductOption(id: 'opt-1', groupId: 'grp-1', name: 'Large'),
            ],
          ),
        ],
      );
      await _pumpForm(
        tester,
        ProductFormPage(product: withOptions),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      // Option groups editor is on the Codes tab (index 3).
      await _goToFormTab(tester, 3);
      expect(find.text('Size'), findsWidgets);
      expect(find.text('Large'), findsWidgets);
    });

    testWidgets('dispatches ProductUpdated on edit submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await _pumpForm(
        tester,
        ProductFormPage(product: existingProduct),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await tester.tap(_saveButton());
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        () => mockProductBloc.add(any(that: isA<ProductUpdated>())),
      ).called(1);
    });

    testWidgets('shows Edit Product title in header', (tester) async {
      await _pumpForm(
        tester,
        ProductFormPage(product: existingProduct),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      expect(find.text('Edit Product'), findsOneWidget);
    });

    testWidgets(
      'shows showProduct toggle outside advanced section when editing',
      (tester) async {
        await _pumpForm(
          tester,
          ProductFormPage(product: existingProduct),
          mockProductBloc,
          mockCategoryBloc,
          mockSettingsCubit,
          productFormCubit,
        );

        expect(find.text('Show product'), findsOneWidget);
      },
    );
  });

  group('UI-BUG-11 regression: stock=0 warning', () {
    testWidgets('shows stock stepper on stock tab', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 2);
      expect(find.byType(StockStepper), findsOneWidget);
    });
  });

  group('T4: price=0 validation', () {
    testWidgets('shows error when price is 0', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await tester.enterText(
        find.byKey(const ValueKey('product-form-name')),
        'Test',
      );
      await _goToFormTab(tester, 1);
      await tester.enterText(
        find.byKey(const ValueKey('product-form-price')),
        '0.00',
      );

      await tester.tap(_saveButton());
      await tester.pumpAndSettle();

      expect(find.text('Price must be greater than 0'), findsOneWidget);
    });
  });

  group('T5: trackStock toggle', () {
    testWidgets('hides stock stepper when trackStock is off', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 2);
      expect(find.byType(StockStepper), findsOneWidget);

      final toggle = _trackStockToggle();
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.byType(StockStepper), findsNothing);
    });

    testWidgets('shows stock stepper when trackStock is toggled back on', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 2);
      final toggle = _trackStockToggle();
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(find.byType(StockStepper), findsOneWidget);
    });
  });

  group('T2: delete flow (edit mode)', () {
    final existingProduct = Product(
      id: 'prod-0001-0001-0001-000000000001',
      name: 'Water',
      price: Money.fromDouble(10.0),
      stock: 100,
      imageThumbnailPath: null,
      isActive: true,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    testWidgets('tapping delete in app bar menu shows confirm dialog', (
      tester,
    ) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await _pumpForm(
        tester,
        ProductFormPage(product: existingProduct),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _openDeleteMenu(tester);
      await tester.tap(find.text('Delete Product'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('confirming delete dispatches ProductDeleted', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await _pumpForm(
        tester,
        ProductFormPage(product: existingProduct),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _openDeleteMenu(tester);
      await tester.tap(find.text('Delete Product'));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      // Twin pills: Cancel + Delete — confirm is the last FilledButton.
      await tester.tap(
        find.descendant(
          of: dialog,
          matching: find.widgetWithText(FilledButton, 'Delete'),
        ),
      );
      await tester.pumpAndSettle();

      verify(
        () => mockProductBloc.add(any(that: isA<ProductDeleted>())),
      ).called(1);
    });

    testWidgets('cancelling delete does not dispatch event', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await _pumpForm(
        tester,
        ProductFormPage(product: existingProduct),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _openDeleteMenu(tester);
      await tester.tap(find.text('Delete Product'));
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      await tester.tap(
        find.descendant(
          of: dialog,
          matching: find.widgetWithText(FilledButton, 'Cancel'),
        ),
      );
      await tester.pumpAndSettle();

      verifyNever(() => mockProductBloc.add(any()));
    });
  });

  group('Draft persistence', () {
    testWidgets('shows restore dialog when draft exists in storage', (
      tester,
    ) async {
      final draftJson = jsonEncode(
        const ProductDraft(name: 'Saved Draft', price: '15.00').toJson(),
      );

      final localCubit = ProductFormCubit(
        _MockSettingsLocalDatasourceWithDraft(draftJson),
        _MockGenerateBarcode(),
        _MockGenerateSku(),
      );

      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        localCubit,
      );

      expect(find.text('Restore draft?'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Discard Draft'), findsOneWidget);

      await localCubit.close();
    });

    testWidgets('discarding draft clears it and does not pre-fill', (
      tester,
    ) async {
      final draftJson = jsonEncode(
        const ProductDraft(name: 'Saved Draft', price: '15.00').toJson(),
      );

      final mockDs = _MockSettingsLocalDatasourceWithDraft(draftJson);
      final localCubit = ProductFormCubit(
        mockDs,
        _MockGenerateBarcode(),
        _MockGenerateSku(),
      );

      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        localCubit,
      );

      await tester.tap(find.text('Discard Draft'));
      await tester.pumpAndSettle();

      expect(find.text('Saved Draft'), findsNothing);

      await localCubit.close();
    });

    testWidgets('restoring draft pre-fills form fields', (tester) async {
      final draftJson = jsonEncode(
        const ProductDraft(
          name: 'Saved Draft',
          price: '15.00',
          stock: '42',
          sku: 'SKU001',
        ).toJson(),
      );

      final localCubit = ProductFormCubit(
        _MockSettingsLocalDatasourceWithDraft(draftJson),
        _MockGenerateBarcode(),
        _MockGenerateSku(),
      );

      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        localCubit,
      );

      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Saved Draft'), findsWidgets);
      await _goToFormTab(tester, 1);
      expect(find.text('15.00'), findsWidgets);

      await localCubit.close();
    });

    testWidgets('does not show restore dialog in edit mode', (tester) async {
      final draftJson = jsonEncode(
        const ProductDraft(name: 'Saved Draft', price: '15.00').toJson(),
      );

      final localCubit = ProductFormCubit(
        _MockSettingsLocalDatasourceWithDraft(draftJson),
        _MockGenerateBarcode(),
        _MockGenerateSku(),
      );

      final product = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Existing',
        price: Money.fromDouble(5.0),
        stock: 10,
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      await _pumpForm(
        tester,
        ProductFormPage(product: product),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        localCubit,
      );

      expect(find.text('Restore draft?'), findsNothing);

      await localCubit.close();
    });
  });

  group('ProductDraft entity', () {
    test('isEmpty returns true for default draft', () {
      expect(const ProductDraft().isEmpty, isTrue);
    });

    test('isEmpty returns false when name is set', () {
      expect(const ProductDraft(name: 'Test').isEmpty, isFalse);
    });

    test('toJson/fromJson round-trip preserves all fields', () {
      const draft = ProductDraft(
        name: 'Coffee',
        price: '50.00',
        stock: '10',
        sku: 'CF-001',
        barcode: '1234567890',
        cost: '30.00',
        categoryId: 'cat-1',
        categoryName: 'Drinks',
        imagePath: '/path/to/img.jpg',
        imageThumbnailPath: '/path/to/thumb.jpg',
        trackStock: false,
        isActive: false,
      );
      final json = draft.toJson();
      final restored = ProductDraft.fromJson(json);
      expect(restored, equals(draft));
    });

    test('copyWith updates only specified fields', () {
      const draft = ProductDraft(name: 'Original', price: '10.00');
      final updated = draft.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.price, '10.00');
    });
  });

  group('Product.copyWith cost sentinel', () {
    test('copyWith without cost preserves original cost', () {
      final product = Product(
        id: '1',
        name: 'Test',
        price: Money.fromDouble(10.0),
        cost: Money.fromDouble(5.0),
        stock: 0,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final updated = product.copyWith(name: 'Updated');
      expect(updated.cost, Money.fromDouble(5.0));
    });

    test('copyWith with explicit null cost sets cost to 0.0', () {
      final product = Product(
        id: '1',
        name: 'Test',
        price: Money.fromDouble(10.0),
        cost: Money.fromDouble(5.0),
        stock: 0,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final updated = product.copyWith(cost: null);
      expect(updated.cost, Money.zero);
    });

    test('copyWith with new cost value updates cost', () {
      final product = Product(
        id: '1',
        name: 'Test',
        price: Money.fromDouble(10.0),
        cost: Money.fromDouble(5.0),
        stock: 0,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final updated = product.copyWith(cost: Money.fromDouble(8.0));
      expect(updated.cost, Money.fromDouble(8.0));
    });
  });

  group('Unsaved changes dialog', () {
    testWidgets('shows Save, Discard, and Cancel buttons', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Test');
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      await navigator.maybePop();
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text("Don't save"), findsOneWidget);
      // StickyActionBar also shows Cancel; dialog Cancel is present too.
      expect(find.text('Cancel'), findsWidgets);
    });
  });

  group('Edit mode: stale product and category fallback', () {
    testWidgets('uses latest product from ProductBloc state when available', (
      tester,
    ) async {
      final originalProduct = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Original',
        price: Money.fromDouble(10.0),
        stock: 100,
        cost: Money.fromDouble(5.0),
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final latestProduct = originalProduct.copyWith(
        name: 'Updated Elsewhere',
        price: Money.fromDouble(20.0),
      );

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: [latestProduct]),
      );
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await _pumpForm(
        tester,
        ProductFormPage(product: originalProduct),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await tester.tap(_saveButton(), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));

      final captor = verify(() => mockProductBloc.add(captureAny())).captured;
      final event = captor.first as ProductUpdated;
      expect(event.product.name, 'Original');
      expect(event.product.price, Money.fromDouble(10.0));
    });

    testWidgets(
      'preserves categoryId from base product when category not loaded',
      (tester) async {
        final product = Product(
          id: 'prod-0001-0001-0001-000000000001',
          name: 'Test',
          price: Money.fromDouble(10.0),
          stock: 100,
          categoryId: 'cat-123',
          imageThumbnailPath: null,
          isActive: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(() => mockProductBloc.state).thenReturn(
          ProductState(status: ProductStatus.success, products: [product]),
        );
        when(() => mockProductBloc.add(any())).thenReturn(null);

        await _pumpForm(
          tester,
          ProductFormPage(product: product),
          mockProductBloc,
          mockCategoryBloc,
          mockSettingsCubit,
          productFormCubit,
        );

        await tester.tap(_saveButton());
        await tester.pump(const Duration(seconds: 1));

        final captor = verify(() => mockProductBloc.add(captureAny())).captured;
        final event = captor.first as ProductUpdated;
        expect(event.product.categoryId, 'cat-123');
      },
    );
  });

  group('Price tab insights', () {
    testWidgets('shows loss warning when cost exceeds price', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await tester.enterText(
        find.byKey(const ValueKey('product-form-name')),
        'Test',
      );
      await _goToFormTab(tester, 1);
      await tester.enterText(
        find.byKey(const ValueKey('product-form-price')),
        '100',
      );
      await tester.enterText(
        find.byKey(const ValueKey('product-form-cost')),
        '120',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('product-form-cost-warning')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Cost is higher than selling price'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty-cost hint when price set without cost', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 1);
      await tester.enterText(
        find.byKey(const ValueKey('product-form-price')),
        '50',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('product-form-cost-empty-hint')),
        findsOneWidget,
      );
      expect(find.textContaining('Add cost to see profit'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('product-form-cost-warning')),
        findsNothing,
      );
    });

    testWidgets('markup chip +50% sets price from cost', (tester) async {
      await _pumpForm(
        tester,
        const ProductFormPage(),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 1);
      await tester.enterText(
        find.byKey(const ValueKey('product-form-cost')),
        '30',
      );
      await tester.pumpAndSettle();

      final chip50 = find.byKey(const ValueKey('product-form-markup-chip-50'));
      await tester.ensureVisible(chip50);
      await tester.pumpAndSettle();
      await tester.tap(chip50);
      await tester.pumpAndSettle();

      final priceField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('product-form-price')),
          matching: find.byType(TextField),
        ),
      );
      expect(priceField.controller?.text, '45.00');
    });

    testWidgets('edit mode shows price delta when price changes', (
      tester,
    ) async {
      final product = Product(
        id: 'prod-0001-0001-0001-000000000099',
        name: 'Priced',
        price: Money.fromDouble(100.0),
        stock: 10,
        cost: Money.fromDouble(60.0),
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: [product]),
      );

      await _pumpForm(
        tester,
        ProductFormPage(product: product),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 1);
      expect(
        find.byKey(const ValueKey('product-form-price-delta')),
        findsNothing,
      );

      await tester.enterText(
        find.byKey(const ValueKey('product-form-price')),
        '120',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('product-form-price-delta')),
        findsOneWidget,
      );
    });
  });

  group('Edit mode: cost clearing', () {
    testWidgets('clearing cost field sends null cost to copyWith', (
      tester,
    ) async {
      final product = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Test',
        price: Money.fromDouble(10.0),
        stock: 100,
        cost: Money.fromDouble(5.0),
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: [product]),
      );
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await _pumpForm(
        tester,
        ProductFormPage(product: product),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 1);
      final costField = find.byKey(const ValueKey('product-form-cost'));
      await tester.ensureVisible(costField);
      await tester.enterText(costField, '');

      await tester.ensureVisible(_saveButton());
      await tester.tap(_saveButton());
      await tester.pump(const Duration(seconds: 1));

      final captor = verify(() => mockProductBloc.add(captureAny())).captured;
      final event = captor.first as ProductUpdated;
      expect(event.product.cost, Money.zero);
    });
  });

  group('Stock sync on trackStock toggle', () {
    testWidgets(
      'restores original stock when trackStock toggled back on in edit mode',
      (tester) async {
        final product = Product(
          id: 'prod-0001-0001-0001-000000000001',
          name: 'Test',
          price: Money.fromDouble(10.0),
          stock: 50,
          trackStock: false,
          imageThumbnailPath: null,
          isActive: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(() => mockProductBloc.state).thenReturn(
          ProductState(status: ProductStatus.success, products: [product]),
        );

        await _pumpForm(
          tester,
          ProductFormPage(product: product),
          mockProductBloc,
          mockCategoryBloc,
          mockSettingsCubit,
          productFormCubit,
        );

        await _goToFormTab(tester, 2);
        expect(find.byType(StockStepper), findsNothing);

        final toggle = find.ancestor(
          of: find.text('Track Stock'),
          matching: find.byType(ModernToggleCard),
        );
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pump(const Duration(seconds: 1));

        // In edit mode with trackStock toggled on, stock shows as read-only with adjust button
        expect(find.byType(StockStepper), findsNothing);
        expect(find.textContaining('50'), findsWidgets);
        expect(find.text('Adjust Stock'), findsOneWidget);
        expect(
          find.textContaining('Change quantity with Adjust stock'),
          findsOneWidget,
        );
      },
    );
  });

  group('Stock tab status and value', () {
    testWidgets(
      'create mode shows stock status and in-stock after qty > threshold',
      (tester) async {
        when(() => mockSettingsCubit.state).thenReturn(
          const SettingsState(
            status: SettingsStatus.loaded,
            settings: Settings(stockConfig: StockConfig(lowStockThreshold: 5)),
          ),
        );

        await _pumpForm(
          tester,
          const ProductFormPage(),
          mockProductBloc,
          mockCategoryBloc,
          mockSettingsCubit,
          productFormCubit,
        );

        await _goToFormTab(tester, 2);
        expect(
          find.byKey(const ValueKey('product-form-stock-status')),
          findsOneWidget,
        );
        // Default stock 0 → out of stock
        expect(find.textContaining('Out of stock'), findsWidgets);

        final stepper = find.byType(StockStepper);
        await tester.ensureVisible(stepper);
        final incBtn = find.descendant(
          of: stepper,
          matching: find.byIcon(Icons.add),
        );
        // 0 → 1 still low stock (threshold 5)
        await tester.tap(incBtn);
        await tester.pumpAndSettle();
        expect(find.textContaining('Low stock'), findsWidgets);
        // Raise above threshold
        for (var i = 0; i < 5; i++) {
          await tester.tap(incBtn);
          await tester.pumpAndSettle();
        }
        expect(find.textContaining('In stock'), findsWidgets);
        expect(find.textContaining('Low stock alert at 5'), findsOneWidget);
      },
    );

    testWidgets('edit mode out of stock shows status and adjust controls', (
      tester,
    ) async {
      final product = Product(
        id: 'prod-0001-0001-0001-000000000099',
        name: 'Empty Stock',
        price: Money.fromDouble(100.0),
        cost: Money.fromDouble(40.0),
        stock: 0,
        trackStock: true,
        unit: 'pcs',
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: [product]),
      );
      when(() => mockSettingsCubit.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.loaded,
          settings: Settings(stockConfig: StockConfig(lowStockThreshold: 5)),
        ),
      );

      await _pumpForm(
        tester,
        ProductFormPage(product: product),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 2);
      expect(find.byType(StockStepper), findsNothing);
      expect(
        find.byKey(const ValueKey('product-form-adjust-stock')),
        findsOneWidget,
      );
      expect(find.textContaining('Out of stock'), findsWidgets);
      expect(
        find.textContaining('Change quantity with Adjust stock'),
        findsOneWidget,
      );
      // stock 0 → value card hidden
      expect(
        find.byKey(const ValueKey('product-form-stock-value')),
        findsNothing,
      );
    });

    testWidgets('edit mode with stock shows inventory value card', (
      tester,
    ) async {
      final product = Product(
        id: 'prod-0001-0001-0001-000000000098',
        name: 'Valued',
        price: Money.fromDouble(100.0),
        cost: Money.fromDouble(40.0),
        stock: 10,
        trackStock: true,
        unit: 'box',
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: [product]),
      );

      await _pumpForm(
        tester,
        ProductFormPage(product: product),
        mockProductBloc,
        mockCategoryBloc,
        mockSettingsCubit,
        productFormCubit,
      );

      await _goToFormTab(tester, 2);
      expect(
        find.byKey(const ValueKey('product-form-stock-value')),
        findsOneWidget,
      );
      expect(find.text('Inventory value'), findsOneWidget);
      expect(find.textContaining('10'), findsWidgets);
      expect(find.textContaining('box'), findsWidgets);
    });
  });
}

class _MockSettingsLocalDatasourceWithDraft extends Mock
    implements SettingsLocalDatasource {
  final String _draftJson;
  _MockSettingsLocalDatasourceWithDraft(this._draftJson);

  @override
  Future<String?> getString(String key) async {
    if (key == 'product_form_draft_v3') return _draftJson;
    return null;
  }

  @override
  Future<void> setString(String key, String value) async {}
}
