import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleProductCard extends StatelessWidget {
  const SaleProductCard({
    super.key,
    required this.product,
    required this.currency,
  });

  final Product product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartQty = context.select<SaleBloc, int>(
      (bloc) => bloc.state.items
          .where((item) => item.product.id == product.id)
          .fold(0, (sum, item) => sum + item.qty),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          final allowOversell = context
              .read<SettingsCubit>()
              .state
              .settings
              .allowOversell;
          context.read<SaleBloc>().add(
            SaleProductAdded(product, allowOversell: allowOversell),
          );
          if (cartQty == 0) {
            AppSnackBar.info(
              context,
              context.l10n.productAddedToCart(product.name),
            );
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.category ?? context.l10n.noCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: MoneyText(
                          value: product.price,
                          currency: currency,
                          style: theme.textTheme.titleMedium,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        product.trackStock
                            ? context.l10n.stockLabel(product.stock)
                            : '\u221e',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: product.trackStock && product.stock <= 5
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (cartQty > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Badge(
                  label: Text('×$cartQty'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
