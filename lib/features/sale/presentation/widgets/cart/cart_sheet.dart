import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/cart_review_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

// Filename is historical ("sheet"); cart entry is full-page only — no modal sheet.
/// Opens cart as a full page (Cupertino push — iOS-style + full screen).
///
/// Named route [SalePaymentRoutes.cartReview] so retail checkout can pop
/// the cart shell before opening the payment page.
///
/// [replacePaymentShell]: when opening cart **from** payment/checkout, use
/// [Navigator.pushReplacement] so pay→cart→pay does not stack orphan payment
/// routes (Wave P3).
Future<void> openCartReviewPage(
  BuildContext context, {
  bool replacePaymentShell = false,
}) {
  final cartBloc = context.read<CartBloc>();
  final checkoutBloc = context.read<CheckoutBloc>();
  final draftBloc = context.read<DraftBloc>();
  final settingsCubit = context.read<SettingsCubit>();

  final route = CupertinoPageRoute<void>(
    settings: const RouteSettings(name: SalePaymentRoutes.cartReview),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cartBloc),
        BlocProvider.value(value: checkoutBloc),
        BlocProvider.value(value: draftBloc),
        BlocProvider.value(value: settingsCubit),
      ],
      child: const CartReviewPage(),
    ),
  );

  final nav = Navigator.of(context);
  if (replacePaymentShell) {
    return nav.pushReplacement<void, void>(route);
  }
  return nav.push<void>(route);
}
