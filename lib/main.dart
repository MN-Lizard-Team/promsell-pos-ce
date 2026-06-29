import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/services/crash_log_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/history/presentation/pages/history_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_list_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/report_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_page.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/splash/app_splash_wrapper.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';
import 'package:promsell_pos_ce/core/theme/app_theme.dart';
import 'package:promsell_pos_ce/core/widgets/nav/bottom_navigation_bar.dart';
import 'package:promsell_pos_ce/core/widgets/nav/nav_swipe_helper.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';

void main() async {
  await runPromsellApp();
}

Future<void> runPromsellApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  configureDependencies();
  final crashLogService = sl<CrashLogService>();

  FlutterError.onError = (details) {
    AppLogger.error(
      'FlutterError',
      error: details.exception,
      stack: details.stack,
    );
    crashLogService.recordError(
      details.exception,
      details.stack,
      context: 'FlutterError',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('PlatformError', error: error, stack: stack);
    crashLogService.recordError(error, stack, context: 'PlatformError');
    return true;
  };

  final settingsCubit = sl<SettingsCubit>();
  await settingsCubit.load();
  runApp(const PromsellApp());
}

class PromsellApp extends StatelessWidget {
  const PromsellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, curr) =>
            prev.settings.locale != curr.settings.locale ||
            prev.settings.themeMode != curr.settings.themeMode ||
            prev.settings.onboardingCompleted !=
                curr.settings.onboardingCompleted,
        builder: (ctx, state) {
          final showOnboarding = !state.settings.onboardingCompleted;
          return MaterialApp(
            title: 'Promsell POS',
            debugShowCheckedModeBanner: false,
            locale: state.settings.locale,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.settings.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: AppSplashWrapper(
              child: showOnboarding
                  ? const OnboardingPage()
                  : const _MainShell(),
            ),
          );
        },
      ),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;
  DateTime? _lastBackPress;

  /// Lazy-loaded tabs: only the active tab is built; previously visited
  /// tabs are kept alive so their state (scroll position, BLoC, etc.) is
  /// preserved when the user switches back.
  final Map<int, Widget> _cachedPages = {};

  static const _pageBuilders = <Widget Function()>[
    SalePage.new,
    ProductListPage.new,
    HistoryPage.new,
    ReportPage.new,
    SettingsPage.new,
  ];

  Widget _pageFor(int i) => _cachedPages.putIfAbsent(i, _pageBuilders[i]);

  void _handleTabTap(int i) {
    if (i != _index) {
      setState(() => _index = i);
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

  void _onSaleLongPress(String key) {
    if (key == 'new_draft') {
      if (_index != 0) setState(() => _index = 0);
      sl<DraftBloc>().add(const DraftCreated());
    }
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

  static final _shortcutMap = <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.digit1): const _SwitchTabIntent(0),
    LogicalKeySet(LogicalKeyboardKey.digit2): const _SwitchTabIntent(1),
    LogicalKeySet(LogicalKeyboardKey.digit3): const _SwitchTabIntent(2),
    LogicalKeySet(LogicalKeyboardKey.digit4): const _SwitchTabIntent(3),
    LogicalKeySet(LogicalKeyboardKey.digit5): const _SwitchTabIntent(4),
    LogicalKeySet(LogicalKeyboardKey.f1): const _SwitchTabIntent(0),
    LogicalKeySet(LogicalKeyboardKey.f2): const _SwitchTabIntent(1),
    LogicalKeySet(LogicalKeyboardKey.f3): const _SwitchTabIntent(2),
    LogicalKeySet(LogicalKeyboardKey.f4): const _SwitchTabIntent(3),
    LogicalKeySet(LogicalKeyboardKey.f5): const _SwitchTabIntent(4),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navItems = [
      NavItem(
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale,
        label: l10n.navSale,
        longPressActions: {'new_draft': l10n.newDraft},
        onLongPressAction: _onSaleLongPress,
      ),
      NavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: l10n.navProducts,
        longPressActions: {'add_product': l10n.addProduct},
        onLongPressAction: _onProductLongPress,
      ),
      NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: l10n.navHistory,
      ),
      NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: l10n.navReport,
      ),
      NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];

    final body = GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      child: IndexedStack(
        index: _index,
        children: [
          for (int i = 0; i < _pageBuilders.length; i++)
            i == _index || _cachedPages.containsKey(i)
                ? _pageFor(i)
                : const SizedBox.shrink(),
        ],
      ),
    );

    return PopScope(
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
        shortcuts: _shortcutMap,
        child: Actions(
          actions: <Type, Action<Intent>>{
            _SwitchTabIntent: CallbackAction<_SwitchTabIntent>(
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
    );
  }
}

class _SwitchTabIntent extends Intent {
  const _SwitchTabIntent(this.index);
  final int index;
}
