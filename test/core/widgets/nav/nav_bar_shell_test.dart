import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/nav/bottom_navigation_bar.dart';

void main() {
  group('NavBar long-press action dispatch', () {
    testWidgets('Sale long-press dispatches new_draft action', (tester) async {
      String? dispatchedKey;
      final items = [
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
          longPressActions: const {'new_draft': 'New Draft'},
          onLongPressAction: (key) => dispatchedKey = key,
        ),
        const NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
        ),
        const NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        const NavItem(
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          label: 'Report',
        ),
        const NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              items: items,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.longPress(find.text('Sale'));
      await tester.pumpAndSettle();

      expect(find.text('New Draft'), findsOneWidget);

      await tester.tap(find.text('New Draft'));
      await tester.pumpAndSettle();

      expect(dispatchedKey, 'new_draft');
    });

    testWidgets('Product long-press dispatches add_product action', (
      tester,
    ) async {
      String? dispatchedKey;
      final items = [
        const NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
          longPressActions: const {'add_product': 'Add Product'},
          onLongPressAction: (key) => dispatchedKey = key,
        ),
        const NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        const NavItem(
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          label: 'Report',
        ),
        const NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              items: items,
              selectedIndex: 1,
              onTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.longPress(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.text('Add Product'), findsOneWidget);

      await tester.tap(find.text('Add Product'));
      await tester.pumpAndSettle();

      expect(dispatchedKey, 'add_product');
    });

    testWidgets('tabs without long-press actions do not show menu', (
      tester,
    ) async {
      final items = const [
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
        ),
        NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        NavItem(
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          label: 'Report',
        ),
        NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              items: items,
              selectedIndex: 2,
              onTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.longPress(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsNothing);
    });
  });

  group('NavBar 5-item rendering', () {
    testWidgets('renders all 5 tabs correctly', (tester) async {
      final items = const [
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
        ),
        NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        NavItem(
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          label: 'Report',
        ),
        NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigationBar(
              items: items,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Expanded), findsNWidgets(5));
      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
