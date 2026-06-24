import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_picker_list_view.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockCategoryBloc mockCategoryBloc;

  final categories = [
    Category(
      id: 'c1',
      name: 'Drinks',
      color: '43A047',
      iconName: 'local_drink_outlined',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
    Category(
      id: 'c2',
      name: 'Foods',
      color: 'E53935',
      iconName: 'restaurant_outlined',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  setUp(() {
    mockCategoryBloc = MockCategoryBloc();
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
  });

  group('CategoryPickerListView', () {
    testWidgets('renders loading state', (tester) async {
      when(
        () => mockCategoryBloc.state,
      ).thenReturn(const CategoryState(status: CategoryStatus.loading));
      await tester.pumpApp(
        CategoryPickerListView(onSelected: (cat) {}),
        categoryBloc: mockCategoryBloc,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state', (tester) async {
      await tester.pumpApp(
        CategoryPickerListView(onSelected: (cat) {}),
        categoryBloc: mockCategoryBloc,
      );

      expect(find.text('No categories yet'), findsOneWidget);
    });

    testWidgets('renders categories', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: categories),
      );
      await tester.pumpApp(
        CategoryPickerListView(onSelected: (cat) {}),
        categoryBloc: mockCategoryBloc,
      );

      expect(find.text('Drinks'), findsOneWidget);
      expect(find.text('Foods'), findsOneWidget);
    });

    testWidgets('renders none option when enabled', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: categories),
      );
      await tester.pumpApp(
        CategoryPickerListView(onSelected: (cat) {}, showNoneOption: true),
        categoryBloc: mockCategoryBloc,
      );

      expect(find.text('No category'), findsOneWidget);
    });

    testWidgets('filters categories by search', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: categories),
      );
      await tester.pumpApp(
        CategoryPickerListView(onSelected: (cat) {}),
        categoryBloc: mockCategoryBloc,
      );

      await tester.enterText(find.byType(SearchBar), 'drink');
      await tester.pump();

      expect(find.text('Drinks'), findsOneWidget);
      expect(find.text('Foods'), findsNothing);
    });
  });
}
