import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_item_list.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_qty_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_sheet_header.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_summary_footer.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartBottomSheet {
  CartBottomSheet._();

  static void show(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.read<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final cartBloc = context.read<CartBloc>();

    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height - mediaQuery.padding.top,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final draggableController = DraggableScrollableController();
        return BlocProvider.value(
          value: cartBloc,
          child: DraggableScrollableSheet(
            controller: draggableController,
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (sheetCtx, scrollController) {
              final bottomInset = MediaQuery.paddingOf(sheetCtx).bottom;
              return Column(
                children: [
                  CartSheetHeader(title: ctx.l10n.cartTitle),
                  CartItemList(
                    scrollController: scrollController,
                    currency: currency,
                    settings: settings,
                    onIncrement: (bloc, item) =>
                        CartActions.changeQty(sheetCtx, bloc, item, 1),
                    onDecrement: (bloc, item) =>
                        CartActions.changeQty(sheetCtx, bloc, item, -1),
                    onQtyTap: (bloc, item, s) => CartQtyDialog.show(
                      sheetCtx,
                      bloc: bloc,
                      item: item,
                      settings: s,
                    ),
                    onDelete: (bloc, item) =>
                        CartActions.removeItem(sheetCtx, bloc, item),
                  ),
                  CartSummaryFooter(
                    bottomInset: bottomInset,
                    currency: currency,
                    settings: settings,
                    onCheckout: () {},
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
