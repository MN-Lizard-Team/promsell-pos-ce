import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    CartBloc? cartBloc,
    CheckoutBloc? checkoutBloc,
    DraftBloc? draftBloc,
    ProductBloc? productBloc,
    CategoryBloc? categoryBloc,
    HistoryBloc? historyBloc,
    SettingsCubit? settingsCubit,
    SearchHistoryCubit? searchHistoryCubit,
    Locale locale = const Locale('en'),
  }) async {
    final providers = <BlocProvider>[
      if (cartBloc != null) BlocProvider<CartBloc>.value(value: cartBloc),
      if (checkoutBloc != null)
        BlocProvider<CheckoutBloc>.value(value: checkoutBloc),
      if (draftBloc != null) BlocProvider<DraftBloc>.value(value: draftBloc),
      if (productBloc != null)
        BlocProvider<ProductBloc>.value(value: productBloc),
      if (categoryBloc != null)
        BlocProvider<CategoryBloc>.value(value: categoryBloc),
      if (historyBloc != null)
        BlocProvider<HistoryBloc>.value(value: historyBloc),
      if (settingsCubit != null)
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      if (searchHistoryCubit != null)
        BlocProvider<SearchHistoryCubit>.value(value: searchHistoryCubit),
    ];

    final app = MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: providers.isEmpty
          ? Scaffold(body: widget)
          : MultiBlocProvider(
              providers: providers,
              child: Scaffold(body: widget),
            ),
    );

    await pumpWidget(app);
    await pump();
  }
}
