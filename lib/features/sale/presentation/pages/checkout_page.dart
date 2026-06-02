import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/cart_review_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout_body.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.paymentTitle),
        actions: [
          BlocBuilder<SaleBloc, SaleState>(
            builder: (_, state) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: state.itemCount > 0,
                  label: Text('${state.itemCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                tooltip: context.l10n.cartTitle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: context.read<SaleBloc>()),
                          BlocProvider.value(
                            value: context.read<SettingsCubit>(),
                          ),
                        ],
                        child: const CartReviewPage(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocProvider.value(
        value: context.read<SaleBloc>(),
        child: BlocProvider.value(
          value: context.read<SettingsCubit>(),
          child: const CheckoutBody(),
        ),
      ),
    );
  }
}
