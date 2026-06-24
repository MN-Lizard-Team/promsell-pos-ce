import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

class MockProductImageService extends Mock implements ProductImageService {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockProductImageService mockImageService;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockImageService = MockProductImageService();
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    if (!GetIt.I.isRegistered<ProductImageService>()) {
      GetIt.I.registerSingleton<ProductImageService>(mockImageService);
    }
    when(
      () => mockProductBloc.state,
    ).thenReturn(const ProductState(status: ProductStatus.success));
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  tearDown(() => GetIt.I.reset());

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
    testWidgets('renders tab-based editor', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(4));
      // Info tab active by default → 3 TextFormFields (name, sku, barcode)
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Info tab still has 3 fields; validation marks name field
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('dispatches ProductAdded on valid submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      // Info tab: enter name
      final nameField = find.byType(TextFormField).at(0);
      await tester.enterText(nameField, 'Water');

      // Switch to Price tab
      await tester.tap(find.text('Price'));
      await tester.pumpAndSettle();

      // Price tab: enter price
      final priceField = find.byType(TextFormField).at(0);
      await tester.enterText(priceField, '10.00');

      // Tap Save in StickyActionBar
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(
        () => mockProductBloc.add(any(that: isA<ProductAdded>())),
      ).called(1);
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
      );

      // Info tab
      expect(find.text('Water'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));

      // Price tab
      await tester.tap(find.text('Price'));
      await tester.pumpAndSettle();
      expect(find.text('10.00'), findsOneWidget);

      // Stock tab
      await tester.tap(find.text('Stock'));
      await tester.pumpAndSettle();
      expect(find.byType(StockStepper), findsOneWidget);
      expect(find.byType(ModernToggleCard), findsOneWidget);

      // Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(ModernToggleCard), findsOneWidget);
    });

    testWidgets('dispatches ProductUpdated on edit submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(
        () => mockProductBloc.add(any(that: isA<ProductUpdated>())),
      ).called(1);
    });
  });

  group('UI-BUG-11 regression: stock=0 warning', () {
    testWidgets('shows stock stepper on Stock tab', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.text('Stock'));
      await tester.pumpAndSettle();

      expect(find.byType(StockStepper), findsOneWidget);
    });
  });
}
