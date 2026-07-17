import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/cart_review_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Opens cart as a full page (default counter path).
///
/// Named route [SalePaymentRoutes.cartReview] so retail checkout can pop
/// the cart shell before showing the payment sheet.
Future<void> openCartReviewPage(BuildContext context) {
  final cartBloc = context.read<CartBloc>();
  final checkoutBloc = context.read<CheckoutBloc>();
  final draftBloc = context.read<DraftBloc>();
  final settingsCubit = context.read<SettingsCubit>();

  return Navigator.of(context).push<void>(
    MaterialPageRoute(
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
    ),
  );
}

/// @nodoc Legacy name — prefer [openCartReviewPage].
@Deprecated('Use openCartReviewPage')
Future<void> showCartSheet(BuildContext context) => openCartReviewPage(context);
