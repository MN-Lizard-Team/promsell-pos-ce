import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_item_tile.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class CartItemList extends StatelessWidget {
  const CartItemList({
    super.key,
    required this.scrollController,
    required this.currency,
    required this.settings,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQtyTap,
    required this.onDelete,
  });

  final ScrollController scrollController;
  final String currency;
  final Settings settings;
  final void Function(CartBloc bloc, CartItem item) onIncrement;
  final void Function(CartBloc bloc, CartItem item) onDecrement;
  final void Function(CartBloc bloc, CartItem item, Settings settings) onQtyTap;
  final void Function(CartBloc bloc, CartItem item) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<CartBloc, CartState>(
          builder: (_, state) {
            if (state.isEmpty) {
              return Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.tapProductToAdd,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.zero,
              itemCount: state.items.length,
              itemBuilder: (listCtx, index) {
                final item = state.items[index];
                final bloc = listCtx.read<CartBloc>();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CartItemTile(
                    item: item,
                    currency: currency,
                    settings: settings,
                    onIncrement: () => onIncrement(bloc, item),
                    onDecrement: () => onDecrement(bloc, item),
                    onQtyTap: () => onQtyTap(bloc, item, settings),
                    onDelete: () => onDelete(bloc, item),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
