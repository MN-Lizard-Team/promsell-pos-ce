import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    SaleBloc? saleBloc,
    ProductBloc? productBloc,
    HistoryBloc? historyBloc,
    SettingsCubit? settingsCubit,
    Locale locale = const Locale('en'),
  }) async {
    final providers = <BlocProvider>[
      if (saleBloc != null) BlocProvider<SaleBloc>.value(value: saleBloc),
      if (productBloc != null)
        BlocProvider<ProductBloc>.value(value: productBloc),
      if (historyBloc != null)
        BlocProvider<HistoryBloc>.value(value: historyBloc),
      if (settingsCubit != null)
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
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
