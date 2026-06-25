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
    ];
  });

  group('AppBottomNavigationBar rendering', () {
    testWidgets('renders correct number of items', (tester) async {
      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      expect(find.byType(Expanded), findsNWidgets(3));
      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('shows active icon for selected tab', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pump();

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.byIcon(Icons.point_of_sale_outlined), findsOneWidget);
    });

    testWidgets('active item has primaryContainer pill', (tester) async {
      await tester.pumpWidget(buildNavBar(selectedIndex: 0));
      await tester.pump();

      final activeContainer = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(activeContainer, isNotEmpty);
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

      await tester.tap(find.text('Sale'));
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
        500,
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
        500,
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
      await tester.pumpWidget(buildNavBar(selectedIndex: 2));
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
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
          longPressActions: const {'new_draft': 'New Draft'},
          onLongPressAction: (key) => actionKey = key,
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
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      await tester.longPress(find.text('Sale'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsOneWidget);
      expect(find.text('New Draft'), findsOneWidget);

      await tester.tap(find.text('New Draft'));
      await tester.pumpAndSettle();

      expect(actionKey, 'new_draft');
    });

    testWidgets('long-press without actions does not show menu', (
      tester,
    ) async {
      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      await tester.longPress(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuItem<String>), findsNothing);
    });
  });

  group('AppBottomNavigationBar badge', () {
    testWidgets('badge dot shows when badgeCount is 0', (tester) async {
      items = const [
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
          badgeCount: 0,
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
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
          badgeCount: 5,
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

      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);

      await tester.pumpWidget(buildNavBar(selectedIndex: 1));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets('Tooltip does not fire on long-press (F2)', (tester) async {
      items = [
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
          longPressActions: const {'new_draft': 'New Draft'},
          onLongPressAction: (_) {},
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
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      await tester.longPress(find.text('Sale'));
      await tester.pumpAndSettle();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.triggerMode, TooltipTriggerMode.manual);
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
        NavItem(
          icon: Icons.point_of_sale_outlined,
          activeIcon: Icons.point_of_sale,
          label: 'Sale',
          longPressActions: const {'new_draft': 'New Draft'},
          onLongPressAction: (_) {},
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
      ];

      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      final navBarBox = tester.getRect(find.byType(AppBottomNavigationBar));

      await tester.longPress(find.text('Sale'));
      await tester.pumpAndSettle();

      expect(find.text('New Draft'), findsOneWidget);

      final menuRect = tester.getRect(find.byType(PopupMenuItem<String>).at(0));
      expect(menuRect.bottom, lessThanOrEqualTo(navBarBox.bottom));
    });

    testWidgets('tab dims on press (F6)', (tester) async {
      await tester.pumpWidget(buildNavBar());
      await tester.pump();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Sale')),
      );
      await tester.pumpAndSettle();

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(opacity.opacity, 0.7);

      await gesture.up();
      await tester.pumpAndSettle();

      final opacityAfter = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(opacityAfter.opacity, 1.0);
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

      final semantics = tester.getSemantics(find.text('Sale'));
      expect(semantics.flagsCollection.isSelected, Tristate.isFalse);
      expect(semantics.flagsCollection.isButton, isTrue);
    });
  });
}
