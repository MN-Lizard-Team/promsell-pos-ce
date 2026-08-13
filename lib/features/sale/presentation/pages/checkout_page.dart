import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_primary_app_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRestaurant = context
        .read<SettingsCubit>()
        .state
        .settings
        .isRestaurantMode;
    final tableBloc = isRestaurant ? context.read<TableBloc>() : null;
    tableBloc?.add(const TablesLoaded());
    final pos = context.posTheme;

    return Scaffold(
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
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CartBloc>()),
          BlocProvider.value(value: context.read<CheckoutBloc>()),
          BlocProvider.value(value: context.read<SettingsCubit>()),
          if (tableBloc != null) BlocProvider.value(value: tableBloc),
        ],
        child: const CheckoutBody(),
      ),
    );
  }
}
