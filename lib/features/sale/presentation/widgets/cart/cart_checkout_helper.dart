import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/checkout_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/payment_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

typedef CheckoutLoadingSetter = void Function(bool loading);

/// Opens checkout: **retail** → payment bottom sheet; **restaurant** → full page.
///
/// Pass [cartBloc]/[checkoutBloc]/[draftBloc]/[settingsCubit] when [context]
/// may sit **above** Sale providers (e.g. after popping Saved Bills on root nav).
void navigateToCheckout(
  BuildContext context, {
  CheckoutLoadingSetter? onLoadingChange,
  CartBloc? cartBloc,
  CheckoutBloc? checkoutBloc,
  DraftBloc? draftBloc,
  SettingsCubit? settingsCubit,
}) {
  final l10n = context.l10n;
  final resolvedSettings = settingsCubit ?? context.read<SettingsCubit>();
  final settings = resolvedSettings.state.settings;
  if (SalesDayLock.isCreateBlocked(
    dailyCloseLock: settings.dailyCloseLock,
    lastClosedDate: settings.lastClosedDate,
  )) {
    AppSnackBar.error(context, l10n.dayClosedMessage);
    return;
  }

  final resolvedCart = cartBloc ?? context.read<CartBloc>();
  if (resolvedCart.state.isEmpty) {
    AppSnackBar.error(context, l10n.cartEmpty);
    return;
  }
  final resolvedCheckout = checkoutBloc ?? context.read<CheckoutBloc>();
  final resolvedDraft = draftBloc ?? context.read<DraftBloc>();

  onLoadingChange?.call(true);
  Timer? fallback;
  fallback = Timer(const Duration(seconds: 3), () {
    onLoadingChange?.call(false);
  });

  void done() {
    fallback?.cancel();
    onLoadingChange?.call(false);
  }

  if (settings.isRestaurantMode) {
    final tableBloc = sl<TableBloc>();
    tableBloc.add(const TablesLoaded());
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            settings: const RouteSettings(name: SalePaymentRoutes.checkoutPage),
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: resolvedCart),
                BlocProvider.value(value: resolvedCheckout),
                BlocProvider.value(value: resolvedDraft),
                BlocProvider.value(value: resolvedSettings),
                BlocProvider.value(value: tableBloc),
              ],
              child: const CheckoutPage(),
            ),
          ),
        )
        .then((_) => done());
    return;
  }

  // Retail: payment sheet on sale root. If cart review (page or legacy modal)
  // is open, close it first so success only needs one pop.
  final navigator = Navigator.of(context);
  final route = ModalRoute.of(context);
  final openedFromModal = route is PopupRoute;
  final openedFromCartReview = SalePaymentRoutes.isCartReview(
    route?.settings.name,
  );

  void openPayment(BuildContext hostContext) {
    showPaymentSheet(
      hostContext,
      cartBloc: resolvedCart,
      checkoutBloc: resolvedCheckout,
      draftBloc: resolvedDraft,
      settingsCubit: resolvedSettings,
    ).whenComplete(done);
  }

  if ((openedFromModal || openedFromCartReview) && navigator.canPop()) {
    navigator.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!navigator.mounted) {
        done();
        return;
      }
      openPayment(navigator.context);
    });
  } else {
    openPayment(context);
  }
}
