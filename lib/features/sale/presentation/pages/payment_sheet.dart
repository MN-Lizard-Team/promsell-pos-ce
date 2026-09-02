import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_primary_app_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Opens retail payment as a full page (same shell as restaurant [CheckoutPage]).
///
/// Prefer this over a modal so keyboard / safe-area / back stack match cart review.
Future<void> openPaymentPage(
  BuildContext context, {
  required CartBloc cartBloc,
  required CheckoutBloc checkoutBloc,
  required DraftBloc draftBloc,
  required SettingsCubit settingsCubit,
  List<String>? selectedItemIds,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      settings: const RouteSettings(name: SalePaymentRoutes.paymentPage),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cartBloc),
          BlocProvider.value(value: checkoutBloc),
          BlocProvider.value(value: draftBloc),
          BlocProvider.value(value: settingsCubit),
        ],
        child: PaymentPage(selectedItemIds: selectedItemIds),
      ),
    ),
  );
}

/// Full-page retail payment shell. Restaurant uses [CheckoutPage].
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key, this.selectedItemIds});

  final List<String>? selectedItemIds;

  @override
  Widget build(BuildContext context) {
    final pos = context.posTheme;

    return KeyedSubtree(
      key: const ValueKey('sale_payment_page'),
      child: Scaffold(
        backgroundColor: pos.catalogBackground,
        appBar: PosPrimaryAppBar(
          title: Text(context.l10n.paymentTitle),
          actions: [
            BlocSelector<CartBloc, CartState, int>(
              selector: (state) => state.itemCount,
              builder: (_, itemCount) {
                return IconButton(
                  icon: Badge(
                    isLabelVisible: itemCount > 0,
                    label: Text('$itemCount'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  tooltip: context.l10n.cartTitle,
                  onPressed: () =>
                      openCartReviewPage(context, replacePaymentShell: true),
                );
              },
            ),
          ],
        ),
        body: CheckoutBody(selectedItemIds: selectedItemIds),
      ),
    );
  }
}
