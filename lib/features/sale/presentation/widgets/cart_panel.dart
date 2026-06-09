import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_header.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_item_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_total_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/sale_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartPanel extends StatefulWidget {
  const CartPanel({
    super.key,
    required this.expanded,
    this.sizePreset,
    this.onSizePresetChanged,
    this.widthPreset,
    this.onWidthPresetChanged,
  });

  final bool expanded;
  final double? sizePreset;
  final ValueChanged<double>? onSizePresetChanged;
  final double? widthPreset;
  final ValueChanged<double>? onWidthPresetChanged;

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  Widget _buildReorderableList(List<CartItem> items, String currency) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: items.length,
      // ignore: deprecated_member_use
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final reordered = List<CartItem>.from(items);
        final moved = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, moved);
        context.read<SaleBloc>().add(
          SaleCartItemsReordered(reordered.map((i) => i.product.id).toList()),
        );
      },
      itemBuilder: (_, index) {
        final item = items[index];
        return Padding(
          key: ValueKey(item.product.id),
          padding: const EdgeInsets.only(bottom: 8),
          child: CartItemRow(
            item: item,
            currency: currency,
            ultraCompact: context
                .watch<SettingsCubit>()
                .state
                .settings
                .ultraCompactMode,
            dragHandleIndex: index,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (prev, curr) => curr.status == SaleStatus.success,
      listener: (ctx, state) {
        final settings = ctx.read<SettingsCubit>().state.settings;
        if (settings.autoPrintPrompt && state.lastSale != null) {
          final sale = state.lastSale!;
          // ADR-009: Defer dialog push to next frame so the modal/page
          // listener can pop first, avoiding route stack corruption.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) SaleReceiptDialog.show(ctx, sale, settings);
          });
        } else {
          AppSnackBar.success(ctx, ctx.l10n.saleSavedSuccess);
          ctx.read<SaleBloc>().add(const SaleReset());
        }
      },
      child: BlocBuilder<SaleBloc, SaleState>(
        builder: (ctx, state) {
          final theme = Theme.of(ctx);
          final items = state.items;

          final content = Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CartHeader(
                  state: state,
                  expanded: widget.expanded,
                  sizePreset: widget.sizePreset,
                  onSizePresetChanged: widget.onSizePresetChanged,
                  widthPreset: widget.widthPreset,
                  onWidthPresetChanged: widget.onWidthPresetChanged,
                ),
                if (state.isEmpty)
                  Expanded(
                    child: AppEmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: ctx.l10n.tapProductToAdd,
                    ),
                  )
                else ...[
                  Expanded(child: _buildReorderableList(items, currency)),
                  CartTotalBar(state: state, currency: currency),
                ],
              ],
            ),
          );

          return content;
        },
      ),
    );
  }
}
