import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/category_field.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_hero_image.dart';
import 'dart:convert';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

class _MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

class _MockGenerateBarcode extends Mock implements GenerateBarcode {}

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
    productFormCubit = ProductFormCubit(mockSettingsDs, _MockGenerateBarcode());

    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    if (!GetIt.I.isRegistered<ProductImageService>()) {
      GetIt.I.registerSingleton<ProductImageService>(MockProductImageService());
    }
    if (!GetIt.I.isRegistered<GenerateBarcode>()) {
      GetIt.I.registerSingleton<GenerateBarcode>(_MockGenerateBarcode());
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
          price: 0,
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
    testWidgets('renders single-scroll form with basic fields visible', (
      tester,
    ) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(FormSectionCard), findsNWidgets(3));
      expect(find.byType(AnimatedCrossFade), findsOneWidget);
      expect(find.byType(StockStepper), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows Add Product title in AppBar', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.text('Add Product'), findsNWidgets(2));
    });

    testWidgets('does not show DangerZoneCard in add mode', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.byType(StickyActionBar), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('shows ProductHeroImage and CategoryField', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.byType(ProductHeroImage), findsOneWidget);
      expect(find.byType(CategoryField), findsOneWidget);
    });

    testWidgets('Advanced section collapsed by default hides advanced fields', (
      tester,
    ) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      final crossFade = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(crossFade.crossFadeState, CrossFadeState.showFirst);
    });

    testWidgets('expanding advanced section shows SKU, Barcode, Cost fields', (
      tester,
    ) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final expandBtn = find.byIcon(Icons.expand_more);
      await tester.ensureVisible(expandBtn);
      await tester.tap(expandBtn);
      await tester.pumpAndSettle();

      expect(find.text('SKU'), findsOneWidget);
      expect(find.text('Barcode'), findsOneWidget);
      expect(find.text('Generate Barcode'), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter product name'), findsOneWidget);
    });

    testWidgets('dispatches ProductAdded on valid submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Water');

      final priceField = find.byType(TextFormField).at(1);
      await tester.enterText(priceField, '10.00');

      await tester.tap(find.byType(FilledButton));
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => mockProductBloc.add(any(that: isA<ProductAdded>())),
      ).called(1);
    });

    testWidgets('shows error when price is empty', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Test');

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter price'), findsOneWidget);
    });

    testWidgets('shows error when barcode has special characters', (
      tester,
    ) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Test');

      final priceField = find.byType(TextFormField).at(1);
      await tester.enterText(priceField, '10.00');

      final expandBtn = find.byIcon(Icons.expand_more);
      await tester.ensureVisible(expandBtn);
      await tester.tap(expandBtn);
      await tester.pumpAndSettle();

      final barcodeField = find.byType(TextFormField).at(3);
      await tester.ensureVisible(barcodeField);
      await tester.enterText(barcodeField, 'ABC-123!');

      final saveBtn = find.byType(FilledButton);
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Barcode must be alphanumeric (letters and numbers only)'),
        findsOneWidget,
      );
    });

    testWidgets('stock stepper increments when + tapped', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

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

  group('ProductFormPage (edit mode)', () {
    final existingProduct = Product(
      id: 'prod-0001-0001-0001-000000000001',
      name: 'Water',
      price: 10.0,
      stock: 100,
      categoryId: 'drinks-001',
      imageThumbnailPath: null,
      isActive: true,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    testWidgets('pre-fills fields with existing product', (tester) async {
      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.text('Water'), findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);
      expect(find.byType(StockStepper), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('dispatches ProductUpdated on edit submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        () => mockProductBloc.add(any(that: isA<ProductUpdated>())),
      ).called(1);
    });

    testWidgets('shows Edit Product title in AppBar', (tester) async {
      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.text('Edit Product'), findsOneWidget);
    });

    testWidgets(
      'shows showProduct toggle outside advanced section when editing',
      (tester) async {
        await tester.pumpApp(
          ProductFormPage(product: existingProduct),
          productBloc: mockProductBloc,
          categoryBloc: mockCategoryBloc,
          settingsCubit: mockSettingsCubit,
          productFormCubit: productFormCubit,
        );

        expect(find.text('Show product'), findsOneWidget);
      },
    );
  });

  group('UI-BUG-11 regression: stock=0 warning', () {
    testWidgets('shows stock stepper in basic section', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.byType(StockStepper), findsOneWidget);
    });
  });

  group('T4: price=0 validation', () {
    testWidgets('shows error when price is 0', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Test');

      final priceField = find.byType(TextFormField).at(1);
      await tester.enterText(priceField, '0.00');

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Price must be greater than 0'), findsOneWidget);
    });
  });

  group('T5: trackStock toggle', () {
    testWidgets('hides stock stepper when trackStock is off', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      expect(find.byType(StockStepper), findsOneWidget);

      final toggle = find.byType(ModernToggleCard);
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(find.byType(StockStepper), findsNothing);
    });

    testWidgets('shows stock stepper when trackStock is toggled back on', (
      tester,
    ) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final toggle = find.byType(ModernToggleCard);
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
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
      price: 10.0,
      stock: 100,
      imageThumbnailPath: null,
      isActive: true,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    testWidgets('tapping delete in StickyActionBar shows confirm dialog', (
      tester,
    ) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final deleteBtn = find.text('Delete');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('confirming delete dispatches ProductDeleted', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final deleteBtn = find.text('Delete');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      await tester.tap(
        find.descendant(of: dialog, matching: find.byType(FilledButton)),
      );
      await tester.pumpAndSettle();

      verify(
        () => mockProductBloc.add(any(that: isA<ProductDeleted>())),
      ).called(1);
    });

    testWidgets('cancelling delete does not dispatch event', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final deleteBtn = find.text('Delete');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      final dialog = find.byType(AlertDialog);
      await tester.tap(
        find.descendant(of: dialog, matching: find.byType(TextButton)),
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
      );

      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: localCubit,
      );
      await tester.pumpAndSettle();

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
      final localCubit = ProductFormCubit(mockDs, _MockGenerateBarcode());

      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: localCubit,
      );
      await tester.pumpAndSettle();

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
      );

      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: localCubit,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Saved Draft'), findsOneWidget);
      expect(find.text('15.00'), findsOneWidget);

      await localCubit.close();
    });

    testWidgets('does not show restore dialog in edit mode', (tester) async {
      final draftJson = jsonEncode(
        const ProductDraft(name: 'Saved Draft', price: '15.00').toJson(),
      );

      final localCubit = ProductFormCubit(
        _MockSettingsLocalDatasourceWithDraft(draftJson),
        _MockGenerateBarcode(),
      );

      final product = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Existing',
        price: 5.0,
        stock: 10,
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      await tester.pumpApp(
        ProductFormPage(product: product),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: localCubit,
      );
      await tester.pumpAndSettle();

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
        price: 10.0,
        cost: 5.0,
        stock: 0,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final updated = product.copyWith(name: 'Updated');
      expect(updated.cost, 5.0);
    });

    test('copyWith with explicit null cost sets cost to 0.0', () {
      final product = Product(
        id: '1',
        name: 'Test',
        price: 10.0,
        cost: 5.0,
        stock: 0,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final updated = product.copyWith(cost: null);
      expect(updated.cost, 0.0);
    });

    test('copyWith with new cost value updates cost', () {
      final product = Product(
        id: '1',
        name: 'Test',
        price: 10.0,
        cost: 5.0,
        stock: 0,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final updated = product.copyWith(cost: 8.0);
      expect(updated.cost, 8.0);
    });
  });

  group('Unsaved changes dialog', () {
    testWidgets('shows Save, Discard, and Cancel buttons', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Test');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Discard Draft'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('Edit mode: stale product and category fallback', () {
    testWidgets('uses latest product from ProductBloc state when available', (
      tester,
    ) async {
      final originalProduct = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Original',
        price: 10.0,
        stock: 100,
        cost: 5.0,
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final latestProduct = originalProduct.copyWith(
        name: 'Updated Elsewhere',
        price: 20.0,
      );

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: [latestProduct]),
      );
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: originalProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));

      final captor = verify(() => mockProductBloc.add(captureAny())).captured;
      final event = captor.first as ProductUpdated;
      expect(event.product.name, 'Original');
      expect(event.product.price, 10.0);
    });

    testWidgets(
      'preserves categoryId from base product when category not loaded',
      (tester) async {
        final product = Product(
          id: 'prod-0001-0001-0001-000000000001',
          name: 'Test',
          price: 10.0,
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

        await tester.pumpApp(
          ProductFormPage(product: product),
          productBloc: mockProductBloc,
          categoryBloc: mockCategoryBloc,
          settingsCubit: mockSettingsCubit,
          productFormCubit: productFormCubit,
        );

        await tester.tap(find.byType(FilledButton));
        await tester.pump(const Duration(seconds: 1));

        final captor = verify(() => mockProductBloc.add(captureAny())).captured;
        final event = captor.first as ProductUpdated;
        expect(event.product.categoryId, 'cat-123');
      },
    );
  });

  group('Edit mode: cost clearing', () {
    testWidgets('clearing cost field sends null cost to copyWith', (
      tester,
    ) async {
      final product = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Test',
        price: 10.0,
        stock: 100,
        cost: 5.0,
        imageThumbnailPath: null,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: [product]),
      );
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: product),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
        productFormCubit: productFormCubit,
      );

      final costField = find.byType(TextFormField).last;
      await tester.ensureVisible(costField);
      await tester.enterText(costField, '');

      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pump(const Duration(seconds: 1));

      final captor = verify(() => mockProductBloc.add(captureAny())).captured;
      final event = captor.first as ProductUpdated;
      expect(event.product.cost, 0.0);
    });
  });

  group('Stock sync on trackStock toggle', () {
    testWidgets(
      'restores original stock when trackStock toggled back on in edit mode',
      (tester) async {
        final product = Product(
          id: 'prod-0001-0001-0001-000000000001',
          name: 'Test',
          price: 10.0,
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

        await tester.pumpApp(
          ProductFormPage(product: product),
          productBloc: mockProductBloc,
          categoryBloc: mockCategoryBloc,
          settingsCubit: mockSettingsCubit,
          productFormCubit: productFormCubit,
        );

        expect(find.byType(StockStepper), findsNothing);

        final toggle = find.ancestor(
          of: find.text('Track Stock'),
          matching: find.byType(ModernToggleCard),
        );
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(StockStepper), findsOneWidget);
        expect(find.text('50'), findsWidgets);
      },
    );
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
