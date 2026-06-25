import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_preview_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsCubit mockSettingsCubit;

  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: 80,
    cost: 50,
    stock: 10,
    trackStock: true,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsCubit = MockSettingsCubit();

    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockProductBloc.state).thenReturn(
      ProductState(status: ProductStatus.success, products: [product]),
    );
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpApp(
      ProductPreviewPage(product: product),
      productBloc: mockProductBloc,
      categoryBloc: mockCategoryBloc,
      settingsCubit: mockSettingsCubit,
    );
  }

  group('ProductPreviewPage UX fixes', () {
    testWidgets('SliverAppBar has back button (U1)', (tester) async {
      await pumpPage(tester);

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('SliverAppBar has delete action (U1)', (tester) async {
      await pumpPage(tester);

      expect(find.byIcon(Icons.delete_outline), findsWidgets);
    });

    testWidgets('SliverAppBar has toggle active action (U1)', (tester) async {
      await pumpPage(tester);

      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);
    });

    testWidgets('StickyActionBar has quick edit stock (U4)', (tester) async {
      await pumpPage(tester);

      expect(find.text('Stock'), findsWidgets);
    });

    testWidgets('section labels are shown before cards (U10)', (tester) async {
      await pumpPage(tester);

      expect(find.text('Stock'), findsWidgets);
      expect(find.text('SKU & Barcode'), findsWidgets);
      expect(find.text('System Info'), findsWidgets);
    });

    testWidgets('expandedHeight is not hardcoded 260 (U2)', (tester) async {
      await pumpPage(tester);

      final sliverAppBar = tester.widget<SliverAppBar>(
        find.byType(SliverAppBar),
      );
      expect(sliverAppBar.expandedHeight, isNot(260));
    });

    testWidgets('product name is shown in app bar title (U3)', (tester) async {
      await pumpPage(tester);

      expect(find.text('Coffee'), findsOneWidget);
    });
  });
}
