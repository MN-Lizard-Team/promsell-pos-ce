import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
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
    final theme = Theme.of(context);
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductForm(context, null),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                if (state.status == ProductStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == ProductStatus.failure) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? context.l10n.errorOccurred,
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }
                final products = state.filtered;
                if (products.isEmpty) {
                  return Center(child: Text(context.l10n.noProductsYet));
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(product.name,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          product.category ?? context.l10n.noCategory,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${context.watch<SettingsCubit>().state.settings.currency}${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.l10n.stockLabel(product.stock),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: product.isInStock ? null : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
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
                  child: Text(ctx.l10n.delete, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
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
            child: Text(context.l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
