import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_result_tile.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsCubit mockSettingsCubit;

  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    sku: 'CFE001',
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  group('SearchResultTile', () {
    testWidgets('renders product name and price', (tester) async {
      await tester.pumpApp(
        SearchResultTile(product: product, query: ''),
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(SearchResultTile), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('50'), findsOneWidget);
    });

    testWidgets('renders match chip', (tester) async {
      await tester.pumpApp(
        SearchResultTile(product: product, query: 'Coff', matchType: 'Name'),
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('renders category name', (tester) async {
      final category = Category(
        id: 'c1',
        name: 'Drinks',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: [category]),
      );
      final productWithCat = product.copyWith(categoryId: 'c1');
      await tester.pumpApp(
        SearchResultTile(product: productWithCat, query: 'Coff'),
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.textContaining('Drinks'), findsOneWidget);
    });
  });
}
