import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/order_channel_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/order_type_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/checkout_body/table_selector.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Restaurant order type / channel / table / external ref block on checkout.
class CheckoutRestaurantSection extends StatelessWidget {
  const CheckoutRestaurantSection({
    super.key,
    required this.orderType,
    required this.orderChannel,
    required this.selectedTableId,
    required this.externalRefCtrl,
    required this.onOrderTypeChanged,
    required this.onOrderChannelChanged,
    required this.onTableSelected,
  });

  final String orderType;
  final String orderChannel;
  final String? selectedTableId;
  final TextEditingController externalRefCtrl;
  final ValueChanged<String> onOrderTypeChanged;
  final ValueChanged<String> onOrderChannelChanged;
  final ValueChanged<String?> onTableSelected;

  @override
  Widget build(BuildContext context) {
    return FormSectionCard(
      icon: Icons.restaurant_outlined,
      title: context.l10n.orderType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderTypeSelector(
            orderType: orderType,
            onChanged: onOrderTypeChanged,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.orderChannel,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          OrderChannelSelector(
            orderChannel: orderChannel,
            onChanged: onOrderChannelChanged,
          ),
          if (orderType == 'dinein') ...[
            const SizedBox(height: 12),
            TableSelector(
              selectedTableId: selectedTableId,
              onSelected: onTableSelected,
            ),
          ],
          if (orderType == 'delivery') ...[
            const SizedBox(height: 12),
            TextField(
              controller: externalRefCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.externalOrderRef,
                hintText: context.l10n.externalOrderRefHint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Seed local restaurant fields from cart state (call once on first build).
  static ({
    String orderType,
    String orderChannel,
    String? tableId,
    String? externalRef,
  })
  seedFromCart(
    CartState cart,
    Settings settings, {
    required bool alreadySeeded,
  }) {
    if (alreadySeeded || !settings.isRestaurantMode) {
      return (
        orderType: cart.orderType.isNotEmpty ? cart.orderType : 'dinein',
        orderChannel: cart.orderChannel.isNotEmpty
            ? cart.orderChannel
            : 'walkin',
        tableId: cart.tableId,
        externalRef: cart.externalOrderRef,
      );
    }
    final ot = cart.orderType;
    final ch = cart.orderChannel;
    return (
      orderType: ot.isNotEmpty ? ot : 'dinein',
      orderChannel: ch.isNotEmpty ? ch : 'walkin',
      tableId: cart.tableId,
      externalRef: cart.externalOrderRef,
    );
  }

  /// Sync order type to cart — clears table when not dinein.
  static void syncOrderTypeToCart(BuildContext context, String orderType) {
    context.read<CartBloc>().add(CartOrderTypeChanged(orderType));
    if (orderType != 'dinein') {
      context.read<CartBloc>().add(const CartTableAssigned(null));
    }
  }

  /// Sync order channel to cart.
  static void syncOrderChannelToCart(BuildContext context, String channel) {
    context.read<CartBloc>().add(CartOrderChannelChanged(channel));
  }

  /// Sync table selection to cart.
  static void syncTableToCart(BuildContext context, String? tableId) {
    context.read<CartBloc>().add(CartTableAssigned(tableId));
  }
}
