import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CategoryListTile', () {
    testWidgets('renders category name and product count', (tester) async {
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Drinks',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          productCount: 5,
        ),
      );

      expect(find.text('Drinks'), findsOneWidget);
      expect(find.textContaining('5'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Food',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('shows delete button when onDelete provided', (tester) async {
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Food',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          onDelete: () {},
        ),
      );

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows selection icon in selection mode', (tester) async {
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Food',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          selectionMode: true,
          selected: true,
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows unselected icon in selection mode', (tester) async {
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Food',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          selectionMode: true,
          selected: false,
        ),
      );

      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });

    testWidgets('opens delete confirmation dialog', (tester) async {
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Food',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          onDelete: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('parseCategoryColor', () {
    test('returns blue for null', () {
      expect(parseCategoryColor(null), Colors.blue);
    });

    test('returns blue for empty string', () {
      expect(parseCategoryColor(''), Colors.blue);
    });

    test('returns color for valid hex', () {
      final color = parseCategoryColor('FF0000');
      expect(color, isA<Color>());
    });

    test('returns blue for invalid hex', () {
      expect(parseCategoryColor('xyz'), Colors.blue);
    });
  });

  group('parseCategoryIcon', () {
    test('returns folder icon for null', () {
      expect(parseCategoryIcon(null), Icons.folder_outlined);
    });

    test('returns folder icon for unknown name', () {
      expect(parseCategoryIcon('unknown'), Icons.folder_outlined);
    });

    test('returns correct icon for known name', () {
      expect(
        parseCategoryIcon('restaurant_outlined'),
        Icons.restaurant_outlined,
      );
    });
  });

  group('CategoryListTile fixes', () {
    testWidgets('has Semantics label for screen readers (C6)', (tester) async {
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Beverages',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          productCount: 3,
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('delete dialog uses dialogContext safely (C4)', (tester) async {
      var deleted = false;
      await tester.pumpApp(
        CategoryListTile(
          category: Category(
            id: 'c1',
            name: 'Food',
            sortOrder: 0,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          onDelete: () => deleted = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pump();

      expect(deleted, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
