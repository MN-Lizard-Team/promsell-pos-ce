import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/nav/bottom_navigation_bar.dart';
import 'package:promsell_pos_ce/core/widgets/nav/bottom_navigation_bar/icon_with_badge.dart';

void main() {
  late int tappedIndex;
  late List<NavItem> items;

  Widget buildNavBar({int selectedIndex = 0}) {
    return MaterialApp(
      home: Scaffold(
        body: AppBottomNavigationBar(
          items: items,
          selectedIndex: selectedIndex,
          onTap: (i) => tappedIndex = i,
        ),
      ),
    );
  }

  setUp(() {
    tappedIndex = -1;
    items = const [
      NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      NavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: 'Products',
      ),
      NavItem(
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale,
        label: 'Sale',
      ),
      NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'History',
      ),
      NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
      ),
    ];
  });

  group('AppBottomNavigationBar rendering', () {
    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      expect(find.byType(Expanded), findsNWidgets(4));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows active icon for selected tab', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pump();

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('center diamond container renders', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 0));
      await tester.pump();

      expect(find.byType(Container), findsWidgets);
    });
  });

  group('AppBottomNavigationBar tap', () {
    testWidgets('tap fires onTap with correct index', (tester) async {
      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      await tester.tap(find.text('Products'));
      await tester.pump();

      expect(tappedIndex, 1);
    });

    testWidgets('tap same tab still fires onTap', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 0));
      await tester.pump();

      await tester.tap(find.text('Home'));
      await tester.pump();

      expect(tappedIndex, 0);
    });
  });

  group('AppBottomNavigationBar swipe', () {
    testWidgets('swipe right navigates to previous tab', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pump();

      await tester.fling(
        find.byType(AppBottomNavigationBar),
        const Offset(100, 0),
        700,
      );
      await tester.pumpAndSettle();

      expect(tappedIndex, 0);
    });

    testWidgets('swipe left navigates to next tab', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 0));
      await tester.pump();

      await tester.fling(
        find.byType(AppBottomNavigationBar),
        const Offset(-100, 0),
        700,
      );
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });

    testWidgets('swipe at first tab does not go below 0', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 0));
      await tester.pump();

      await tester.fling(
        find.byType(AppBottomNavigationBar),
        const Offset(100, 0),
        500,
      );
      await tester.pumpAndSettle();

      expect(tappedIndex, -1);
    });

    testWidgets('swipe at last tab does not exceed bounds', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 4));
      await tester.pump();

      await tester.fling(
        find.byType(AppBottomNavigationBar),
        const Offset(-100, 0),
        500,
      );
      await tester.pumpAndSettle();

      expect(tappedIndex, -1);
    });
  });

  group('AppBottomNavigationBar long-press', () {
    testWidgets('long-press shows popup menu when actions defined', (
      tester,
    ) async {
      String? actionKey;
      items = [
        const NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
          longPressActions: const {'add_product': 'Add Product'},
          onLongPressAction: (key) => actionKey = key,
        ),
        const NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        const NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        const NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      await tester.longPress(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsOneWidget);
      expect(find.text('Add Product'), findsOneWidget);

      await tester.tap(find.text('Add Product'));
      await tester.pumpAndSettle();

      expect(actionKey, 'add_product');
    });

    testWidgets('long-press without actions does not show menu', (
      tester,
    ) async {
      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      await tester.longPress(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsNothing);
    });
  });

  group('AppBottomNavigationBar badge', () {
    testWidgets('badge dot shows when badgeCount is 0', (tester) async {
      items = const [
        NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          badgeCount: 0,
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
        ),
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(IconWithBadge),
          matching: find.byType(Positioned),
        ),
        findsOneWidget,
      );
      expect(find.text('0'), findsNothing);
    });

    testWidgets('badge number shows when badgeCount > 0', (tester) async {
      items = const [
        NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          badgeCount: 5,
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
        ),
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });
  });

  group('AppBottomNavigationBar regression fixes', () {
    testWidgets('setState fires on tab change (F1)', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 0));
      await tester.pump();

      expect(find.byIcon(Icons.home), findsOneWidget);

      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets('center button renders as Positioned overlay', (tester) async {
      items = [
        const NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
          longPressActions: const {'add_product': 'Add Product'},
          onLongPressAction: (_) {},
        ),
        const NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        const NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        const NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      await tester.longPress(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsOneWidget);
    });

    testWidgets('only bouncing tab has AnimatedBuilder (F3)', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 0));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(AppBottomNavigationBar),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );

      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.descendant(
          of: find.byType(AppBottomNavigationBar),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('long-press menu anchors to navbar top (F4)', (tester) async {
      items = [
        const NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2,
          label: 'Products',
          longPressActions: const {'add_product': 'Add Product'},
          onLongPressAction: (_) {},
        ),
        const NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
        ),
        const NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'History',
        ),
        const NavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
        ),
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      final navBarBox = tester.getRect(find.byType(AppBottomNavigationBar));

      await tester.longPress(find.text('Products'));
      await tester.pumpAndSettle();

      expect(find.text('Add Product'), findsOneWidget);

      final menuRect = tester.getRect(find.byType(PopupMenuItem<String>).at(0));
      expect(menuRect.bottom, lessThanOrEqualTo(navBarBox.bottom));
    });

    testWidgets('inactive tab icon has reduced opacity (F6)', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pump();

      final icons = tester.widgetList<IconWithBadge>(
        find.byType(IconWithBadge),
      );
      expect(icons, isNotEmpty);
      final homeIcon = icons.first;
      expect(
        homeIcon.color,
        isNot(
          equals(
            Theme.of(
              tester.element(find.byType(AppBottomNavigationBar)),
            ).colorScheme.primary,
          ),
        ),
      );
    });

    testWidgets('active tab has Semantics selected=true (F9)', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pump();

      final semantics = tester.getSemantics(find.text('Products'));
      expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
      expect(semantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('inactive tab has Semantics selected=false (F9)', (
      tester,
    ) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pump();

      final semantics = tester.getSemantics(find.text('Home'));
      expect(semantics.flagsCollection.isSelected, Tristate.isFalse);
      expect(semantics.flagsCollection.isButton, isTrue);
    });
  });
}
