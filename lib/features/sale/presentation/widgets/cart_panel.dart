import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_header.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_item_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_total_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/sale_receipt_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key, required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (prev, curr) => curr.status == SaleStatus.success,
      listener: (ctx, state) {
        final settings = ctx.read<SettingsCubit>().state.settings;
        if (settings.autoPrintPrompt && state.lastSale != null) {
          final sale = state.lastSale!;
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
          final content = Card(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CartHeader(state: state),
                if (state.isEmpty)
                  Expanded(
                    child: AppEmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: ctx.l10n.tapProductToAdd,
                    ),
                  )
                else ...[
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) => CartItemRow(
                        item: state.items[index],
                        currency: currency,
                      ),
                    ),
                  ),
                  CartTotalBar(state: state, currency: currency),
                ],
              ],
            ),
          );

          if (expanded) return content;

          final cartHeight = state.isEmpty ? 120.0 : null;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: cartHeight != null
                ? SizedBox(height: cartHeight, child: content)
                : ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 200,
                      maxHeight: 360,
                    ),
                    child: content,
                  ),
          );
        },
      ),
    );
  }
}
