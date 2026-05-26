import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(
        getProducts: sl(),
        addProduct: sl(),
        updateProduct: sl(),
        deleteProduct: sl(),
      )..add(const ProductsSubscribed()),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatefulWidget {
  const _ProductListView();

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) =>
          curr.status == ProductStatus.failure &&
          prev.status != ProductStatus.failure,
      listener: (ctx, state) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? ctx.l10n.errorOccurred),
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.productsTitle),
          actions: [
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addProduct),
              onPressed: () => _showProductForm(context, null),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: SearchBar(
                  controller: _searchController,
                  hintText: context.l10n.searchProducts,
                  leading: const Icon(Icons.search),
                  onChanged: (q) =>
                      context.read<ProductBloc>().add(ProductSearchChanged(q)),
                ),
              ),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state.status == ProductStatus.loading ||
                        state.status == ProductStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == ProductStatus.failure) {
                      return AppEmptyState(
                        icon: Icons.error_outline,
                        title: state.errorMessage ?? context.l10n.errorOccurred,
                      );
                    }
                    final products = state.filtered;
                    if (products.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: context.l10n.noProductsYet,
                        message: context.l10n.searchProducts,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          _ProductTile(product: products[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, Product? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: ProductFormPage(product: product),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final statusColor = product.isInStock
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showEdit(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.7,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category ?? context.l10n.noCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          context.l10n.stockLabel(product.stock),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    value: product.price,
                    currency: currency,
                    style: theme.textTheme.titleMedium,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 6),
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'edit':
                          _showEdit(context);
                        case 'delete':
                          _confirmDelete(context);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(value: 'edit', child: Text(ctx.l10n.edit)),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          ctx.l10n.delete,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: ProductFormPage(product: product),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteProduct),
        content: Text(context.l10n.confirmDeleteProduct(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(ProductDeleted(product.id));
              Navigator.pop(context);
            },
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
