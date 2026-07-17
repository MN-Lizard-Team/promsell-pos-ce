import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_preview_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

class _MockGenerateBarcode extends Mock implements GenerateBarcode {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsCubit mockSettingsCubit;
  late StreamController<ProductState> productStream;

  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(80),
    cost: Money.fromDouble(50),
    stock: 10,
    trackStock: true,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(const ProductDeleted('fallback-id'));
  });

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsCubit = MockSettingsCubit();
    productStream = StreamController<ProductState>.broadcast();

    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockProductBloc.state).thenReturn(
      ProductState(status: ProductStatus.success, products: [product]),
    );
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    when(() => mockProductBloc.stream).thenAnswer((_) => productStream.stream);
    // Simulate successful delete: product leaves the list after ProductDeleted.
    when(() => mockProductBloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.first;
      if (event is ProductDeleted) {
        final next = const ProductState(
          status: ProductStatus.success,
          products: [],
          saveStatus: ProductSaveStatus.saved,
        );
        when(() => mockProductBloc.state).thenReturn(next);
        if (!productStream.isClosed) {
          productStream.add(next);
        }
      }
    });
  });

  tearDown(() async {
    await productStream.close();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpApp(
      ProductPreviewPage(
        product: product,
        generateBarcode: _MockGenerateBarcode(),
        watchInventoryLogs: MockWatchInventoryLogs(),
      ),
      productBloc: mockProductBloc,
      categoryBloc: mockCategoryBloc,
      settingsCubit: mockSettingsCubit,
    );
  }

  group('ProductPreviewPage UX fixes', () {
    testWidgets('Header has back button (U1)', (tester) async {
      await pumpPage(tester);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Bottom bar does not have delete action', (tester) async {
      await pumpPage(tester);

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('AppBar has toggle active action (U1)', (tester) async {
      await pumpPage(tester);

      expect(find.byTooltip('Deactivate'), findsOneWidget);
    });

    testWidgets('TabBar shows 4 tabs', (tester) async {
      await pumpPage(tester);

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Product Info'), findsWidgets);
      expect(find.text('Stock'), findsWidgets);
      expect(find.text('Price'), findsWidgets);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('Bottom bar has Adjust Stock and Edit buttons', (tester) async {
      await pumpPage(tester);

      expect(find.text('Edit Product'), findsOneWidget);
      expect(find.text('Adjust Stock'), findsOneWidget);
    });

    testWidgets('InfoTab shows product info on first tab', (tester) async {
      await pumpPage(tester);

      expect(find.text('Product Info'), findsWidgets);
    });

    testWidgets('product name is shown in summary card (U3)', (tester) async {
      await pumpPage(tester);

      expect(find.text('Coffee'), findsWidgets);
    });
  });

  group('ProductPreviewPage interactions', () {
    testWidgets('delete via menu shows confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      final deleteItem = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Delete Product'),
      );
      await tester.tap(deleteItem);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('confirming delete via menu dispatches ProductDeleted', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpPage(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      final deleteItem = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Delete Product'),
      );
      await tester.tap(deleteItem);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      // Loading dialog uses CircularProgressIndicator (never "settles").
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      verify(() => mockProductBloc.add(const ProductDeleted('p1'))).called(1);
    });

    testWidgets('tapping toggle active dispatches ProductUpdated', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byTooltip('Deactivate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => mockProductBloc.add(
          ProductUpdated(product.copyWith(isActive: false)),
        ),
      ).called(1);
    });

    testWidgets('bottom bar has 2 actions (Adjust Stock, Edit)', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.byIcon(Icons.swap_horiz), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.text('Adjust Stock'), findsOneWidget);
      expect(find.text('Edit Product'), findsOneWidget);
    });
  });
}
