import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/history/presentation/pages/history_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_list_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/report_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_page_redesign.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_page.dart';
import 'package:promsell_pos_ce/core/theme/app_theme.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await sl<SettingsCubit>().load();
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
            prev.settings.themeMode != curr.settings.themeMode,
        builder: (ctx, state) {
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
            home: const _MainShell(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (int i = 0; i < _pageBuilders.length; i++)
            i == _index || _cachedPages.containsKey(i)
                ? _pageFor(i)
                : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i != _index) {
            setState(() => _index = i);
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.point_of_sale_outlined),
            selectedIcon: const Icon(Icons.point_of_sale),
            label: context.l10n.navSale,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: context.l10n.navProducts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: context.l10n.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: context.l10n.navReport,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
