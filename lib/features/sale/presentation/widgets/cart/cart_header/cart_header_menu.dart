import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartHeaderMenu extends StatelessWidget {
  const CartHeaderMenu({
    super.key,
    required this.cartState,
    required this.onToggleCompact,
    required this.onNewDraft,
    required this.onClearCart,
  });

  final CartState cartState;
  final VoidCallback onToggleCompact;
  final VoidCallback onNewDraft;
  final VoidCallback onClearCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (_, settingsState) {
        final isUltra = settingsState.settings.ultraCompactMode;
        return PopupMenuButton<String>(
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'toggle_compact',
              child: Row(
                children: [
                  Icon(
                    isUltra ? Icons.density_small : Icons.view_agenda,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isUltra
                        ? context.l10n.cartCompactNormal
                        : context.l10n.cartCompactUltra,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'new_draft',
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 10),
                  Text(context.l10n.newDraft),
                ],
              ),
            ),
            if (!cartState.isEmpty)
              PopupMenuItem(
                value: 'clear_cart',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.clearCart,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'toggle_compact':
                onToggleCompact();
              case 'new_draft':
                onNewDraft();
              case 'clear_cart':
                onClearCart();
            }
          },
        );
      },
    );
  }
}
