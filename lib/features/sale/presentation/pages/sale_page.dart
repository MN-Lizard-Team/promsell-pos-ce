import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/payment_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc(
            getProducts: sl(),
            addProduct: sl(),
            updateProduct: sl(),
            deleteProduct: sl(),
          )..add(const ProductsSubscribed()),
        ),
        BlocProvider(create: (_) => SaleBloc(createSale: sl())),
      ],
      child: const _SaleView(),
    );
  }
}

class _SaleView extends StatelessWidget {
  const _SaleView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.salePageTitle),
        actions: [
          BlocBuilder<SaleBloc, SaleState>(
            builder: (ctx, state) => state.isEmpty
                ? const SizedBox.shrink()
                : TextButton.icon(
                    onPressed: () =>
                        ctx.read<SaleBloc>().add(const SaleCartCleared()),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: Text(
                      ctx.l10n.clearCart,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 3, child: _ProductGrid()),
          const Divider(height: 1),
          Expanded(flex: 2, child: _CartPanel()),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (ctx, state) {
        if (state.status == ProductStatus.loading ||
            state.status == ProductStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = state.products
            .where((p) => p.isActive && p.isInStock)
            .toList();
        if (products.isEmpty) {
          return Center(child: Text(ctx.l10n.noProducts));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            mainAxisExtent: 90,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => _ProductCard(product: products[i]),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.read<SaleBloc>().add(SaleProductAdded(product)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$currency${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (prev, curr) => curr.status == SaleStatus.success,
      listener: (ctx, state) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text(ctx.l10n.saleSavedSuccess)));
      },
      child: BlocBuilder<SaleBloc, SaleState>(
        builder: (ctx, state) {
          if (state.isEmpty) {
            return Center(
              child: Text(
                ctx.l10n.tapProductToAdd,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (_, i) => _CartItemRow(item: state.items[i]),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ctx.l10n.cartTotal,
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          '$currency${state.total.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _showPayment(ctx, state),
                      icon: const Icon(Icons.payment),
                      label: Text(ctx.l10n.checkout(state.itemCount)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPayment(BuildContext context, SaleState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SaleBloc>(),
        child: PaymentSheet(total: state.total),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.product.name,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => context.read<SaleBloc>().add(
                  SaleItemQtyChanged(
                    productId: item.product.id,
                    qty: item.qty - 1,
                  ),
                ),
              ),
              Text('${item.qty}', style: theme.textTheme.bodyMedium),
              IconButton(
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => context.read<SaleBloc>().add(
                  SaleItemQtyChanged(
                    productId: item.product.id,
                    qty: item.qty + 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 72,
            child: Text(
              '$currency${item.subtotal.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
