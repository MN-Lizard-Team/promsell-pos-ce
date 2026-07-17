import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_payment_routes.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Live retail payment shell (bottom sheet). Restaurant uses [CheckoutPage].
Future<void> showPaymentSheet(
  BuildContext context, {
  required CartBloc cartBloc,
  required CheckoutBloc checkoutBloc,
  required DraftBloc draftBloc,
  required SettingsCubit settingsCubit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: true,
    showDragHandle: false,
    routeSettings: const RouteSettings(name: SalePaymentRoutes.paymentSheet),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cartBloc),
        BlocProvider.value(value: checkoutBloc),
        BlocProvider.value(value: draftBloc),
        BlocProvider.value(value: settingsCubit),
      ],
      child: const PaymentSheet(),
    ),
  );
}

class PaymentSheet extends StatelessWidget {
  const PaymentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final height = MediaQuery.sizeOf(context).height;
    // Single keyboard lift at the shell; CheckoutBody must not add viewInsets.
    final maxSheetHeight = height * 0.9;

    return KeyedSubtree(
      key: const ValueKey('sale_payment_sheet'),
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: SizedBox(
            height: maxSheetHeight,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.paymentTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const Expanded(child: CheckoutBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
