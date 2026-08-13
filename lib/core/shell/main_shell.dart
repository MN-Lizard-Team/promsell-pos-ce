import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/nav/bottom_navigation_bar.dart';
import 'package:promsell_pos_ce/core/widgets/nav/nav_swipe_helper.dart';
import 'package:promsell_pos_ce/core/shell/keyboard_shortcuts.dart';
import 'package:promsell_pos_ce/core/shell/main_shell_scope.dart';
import 'package:promsell_pos_ce/features/home/presentation/pages/home_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_list_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/report_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;
  DateTime? _lastBackPress;

  final Map<int, Widget> _cachedPages = {};

  static const _pageBuilders = <Widget Function()>[
    HomePage.new,
    ProductListPage.new,
    SalePage.new,
    ReportPage.new,
    SettingsPage.new,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      try {
        sl<AppLockService>().lockSession();
      } catch (e, stack) {
        AppLogger.warning('lockSession failed', error: e, stack: stack);
      }
      try {
        final cart = sl<CartBloc>().state;
        if (!cart.isEmpty && !cart.paymentLocked) {
          sl<DraftBloc>().add(DraftForceSaveRequested(cart));
        }
      } catch (e, stack) {
        AppLogger.warning('Draft force-save failed', error: e, stack: stack);
      }
    }
  }

  Widget _pageFor(int i) => _cachedPages.putIfAbsent(i, _pageBuilders[i]);

  void _handleTabTap(int i) {
    if (i != _index) {
      setState(() => _index = i);
      if (i == 1) {
        try {
          sl<ProductBloc>().add(
            const ProductSurfaceEntered(ProductSurface.catalog),
          );
        } catch (e, stack) {
          AppLogger.warning(
            'ProductSurfaceEntered(catalog) failed',
            error: e,
            stack: stack,
          );
        }
      } else if (i == 2) {
        try {
          sl<ProductBloc>().add(
            const ProductSurfaceEntered(ProductSurface.sale),
          );
        } catch (e, stack) {
          AppLogger.warning(
            'ProductSurfaceEntered(sale) failed',
            error: e,
            stack: stack,
          );
        }
      }
    } else {
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    final controller = PrimaryScrollController.maybeOf(context);
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSwipe(DragEndDetails details) {
    NavSwipeHelper.handleSwipe(
      details,
      _index,
      _pageBuilders.length,
      _handleTabTap,
    );
  }

  Future<void> _onSaleLongPress(String key) async {
    if (key != 'new_draft') return;
    final cart = sl<CartBloc>().state;
    if (cart.paymentLocked) {
      AppSnackBar.warning(context, context.l10n.cartPaymentInProgress);
      return;
    }
    if (!cart.isEmpty) {
      final confirmed = await showConfirmationDialog(
        context,
        title: context.l10n.clearCart,
        message: context.l10n.confirmClearCart,
        confirmLabel: context.l10n.clearCart,
        destructive: true,
      );
      if (!confirmed || !mounted) return;
      if (sl<CartBloc>().state.paymentLocked) {
        AppSnackBar.warning(context, context.l10n.cartPaymentInProgress);
        return;
      }
    }
    if (_index != 2) setState(() => _index = 2);
    sl<DraftBloc>().add(const DraftCreated());
    sl<CartBloc>().add(const CartCleared());
  }

  void _onProductLongPress(String key) {
    if (key == 'add_product') {
      if (_index != 1) setState(() => _index = 1);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<ProductBloc>()),
              BlocProvider.value(value: sl<CategoryBloc>()),
              BlocProvider(create: (_) => sl<ProductFormCubit>()),
            ],
            child: const ProductFormPage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navItems = [
      NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: l10n.navHome,
      ),
      NavItem(
        icon: TablerIcons.cube,
        activeIcon: TablerIcons.cubeUnfolded,
        label: l10n.navProducts,
        longPressActions: {'add_product': l10n.addProduct},
        onLongPressAction: _onProductLongPress,
      ),
      NavItem(
        icon: TablerIcons.buildingStore,
        activeIcon: TablerIcons.buildingStore,
        label: l10n.navSale,
        longPressActions: {'new_draft': l10n.newDraft},
        onLongPressAction: _onSaleLongPress,
      ),
      NavItem(
        icon: TablerIcons.chartBar,
        activeIcon: TablerIcons.chartPieFilled,
        label: l10n.navReport,
      ),
      NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];

    final body = MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider.value(value: sl<CategoryBloc>()),
        BlocProvider.value(value: sl<CartBloc>()),
        BlocProvider.value(value: sl<DraftBloc>()),
      ],
      child: GestureDetector(
        onHorizontalDragEnd: _handleSwipe,
        child: IndexedStack(
          index: _index,
          children: [
            for (int i = 0; i < _pageBuilders.length; i++)
              i == _index || _cachedPages.containsKey(i)
                  ? TickerMode(enabled: i == _index, child: _pageFor(i))
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );

    return MainShellScope(
      goToTab: _handleTabTap,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          final now = DateTime.now();
          if (_lastBackPress != null &&
              now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
            SystemNavigator.pop();
          } else {
            _lastBackPress = now;
            AppSnackBar.info(context, l10n.pressBackAgainToExit);
          }
        },
        child: Shortcuts(
          shortcuts: tabShortcuts,
          child: Actions(
            actions: <Type, Action<Intent>>{
              SwitchTabIntent: CallbackAction<SwitchTabIntent>(
                onInvoke: (intent) => _handleTabTap(intent.index),
              ),
            },
            child: Focus(
              autofocus: true,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth >= 600;
                  if (isTablet) {
                    return Scaffold(
                      body: Row(
                        children: [
                          NavigationRail(
                            selectedIndex: _index,
                            onDestinationSelected: _handleTabTap,
                            labelType: NavigationRailLabelType.selected,
                            destinations: navItems
                                .map(
                                  (item) => NavigationRailDestination(
                                    icon: Icon(item.icon),
                                    selectedIcon: Icon(item.activeIcon),
                                    label: Text(item.label),
                                  ),
                                )
                                .toList(),
                          ),
                          const VerticalDivider(thickness: 1, width: 1),
                          Expanded(child: body),
                        ],
                      ),
                    );
                  }
                  return Scaffold(
                    body: body,
                    bottomNavigationBar: AppBottomNavigationBar(
                      selectedIndex: _index,
                      onTap: _handleTabTap,
                      items: navItems,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
