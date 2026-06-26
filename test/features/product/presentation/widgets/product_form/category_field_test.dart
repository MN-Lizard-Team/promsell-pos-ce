import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/category_field.dart';
import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  group('CategoryField', () {
    late MockCategoryBloc mockCategoryBloc;

    setUp(() {
      mockCategoryBloc = MockCategoryBloc();
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(
          status: CategoryStatus.success,
          categories: [
            Category(
              id: 'cat-001',
              name: 'Drinks',
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
            ),
          ],
        ),
      );
    });

    final testCategory = Category(
      id: 'cat-001',
      name: 'Drinks',
      color: '#FF5722',
      iconName: 'local_drink',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    testWidgets('displays no category selected when null', (tester) async {
      await tester.pumpApp(
        CategoryField(selectedCategory: null, onChanged: (_) {}),
        categoryBloc: mockCategoryBloc,
      );

      expect(find.text('No category selected'), findsOneWidget);
    });

    testWidgets('displays category name when selected', (tester) async {
      await tester.pumpApp(
        CategoryField(selectedCategory: testCategory, onChanged: (_) {}),
        categoryBloc: mockCategoryBloc,
      );

      expect(find.text('Drinks'), findsOneWidget);
    });

    testWidgets('shows chevron icon', (tester) async {
      await tester.pumpApp(
        CategoryField(selectedCategory: testCategory, onChanged: (_) {}),
        categoryBloc: mockCategoryBloc,
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onChanged with null when None is selected', (
      tester,
    ) async {
      Category? captured;
      await tester.pumpApp(
        CategoryField(
          selectedCategory: testCategory,
          onChanged: (cat) => captured = cat,
        ),
        categoryBloc: mockCategoryBloc,
      );

      await tester.tap(find.byType(CategoryField));
      await tester.pumpAndSettle();

      expect(find.text('No category'), findsOneWidget);
      await tester.tap(find.text('No category'));
      await tester.pumpAndSettle();

      expect(captured, isNull);
    });

    testWidgets('does not call onChanged when dismissed without selection', (
      tester,
    ) async {
      var called = false;
      await tester.pumpApp(
        CategoryField(
          selectedCategory: testCategory,
          onChanged: (_) => called = true,
        ),
        categoryBloc: mockCategoryBloc,
      );

      await tester.tap(find.byType(CategoryField));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });
  });
}
