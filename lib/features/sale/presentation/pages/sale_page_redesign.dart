import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/adaptive_breakpoints.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/payment_sheet_redesign.dart';
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
    final isExpanded = AdaptiveBreakpoints.isExpanded(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.salePageTitle)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, isExpanded ? 12 : 8),
          child: isExpanded
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _SaleCatalog()),
                    SizedBox(width: 12),
                    SizedBox(width: 390, child: _CartPanel(expanded: true)),
                  ],
                )
              : const Column(
                  children: [
                    Expanded(child: _SaleCatalog()),
                    SizedBox(height: 8),
                    _CartPanel(expanded: false),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SaleCatalog extends StatefulWidget {
  const _SaleCatalog();

  @override
  State<_SaleCatalog> createState() => _SaleCatalogState();
}

class _SaleCatalogState extends State<_SaleCatalog> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBar(
          controller: _searchController,
          hintText: context.l10n.saleSearchProducts,
          leading: const Icon(Icons.search),
          onChanged: (query) =>
              context.read<ProductBloc>().add(ProductSearchChanged(query)),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (ctx, state) {
              if (state.status == ProductStatus.loading ||
                  state.status == ProductStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == ProductStatus.failure) {
                return AppEmptyState(
                  icon: Icons.error_outline,
                  title: state.errorMessage ?? ctx.l10n.errorOccurred,
                );
              }

              final activeProducts = state.filtered
                  .where((product) => product.isActive && product.isInStock)
                  .toList();
              final categories = _categoriesOf(activeProducts);
              final selectedCategory = categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : null;
              final products = selectedCategory == null
                  ? activeProducts
                  : activeProducts
                        .where(
                          (product) => product.category == selectedCategory,
                        )
                        .toList();

              if (activeProducts.isEmpty) {
                return AppEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: ctx.l10n.noProducts,
                  message: ctx.l10n.tapProductToAdd,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final isAll = index == 0;
                        final category = isAll ? null : categories[index - 1];
                        final selected = selectedCategory == category;

                        return ChoiceChip(
                          label: Text(
                            isAll ? ctx.l10n.allCategories : category!,
                          ),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = category),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (products.isEmpty)
                    Expanded(
                      child: AppEmptyState(
                        icon: Icons.search_off,
                        title: ctx.l10n.noProducts,
                      ),
                    )
                  else
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 720;

                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: isWide ? 210 : 176,
                                  mainAxisExtent: isWide ? 132 : 122,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: products.length,
                            itemBuilder: (_, index) => _ProductCard(
                              product: products[index],
                              currency: currency,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Text(
          context.l10n.tapProductToAdd,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<String> _categoriesOf(List<Product> products) {
    final categories =
        products
            .map((product) => product.category?.trim())
            .whereType<String>()
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return categories;
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.currency});

  final Product product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.read<SaleBloc>().add(SaleProductAdded(product));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
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
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                    context.l10n.stockLabel(product.stock),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({required this.expanded});

  final bool expanded;

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
          final content = Card(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CartHeader(state: state),
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
                      itemBuilder: (_, index) => _CartItemRow(
                        item: state.items[index],
                        currency: currency,
                      ),
                    ),
                  ),
                  _CartTotalBar(state: state, currency: currency),
                ],
              ],
            ),
          );

          if (expanded) return content;

          return SizedBox(
            height: state.isEmpty ? 184 : 292,
            child: DecoratedBox(
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
              child: content,
            ),
          );
        },
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.state});

  final SaleState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.cartTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!state.isEmpty)
            TextButton.icon(
              onPressed: () =>
                  context.read<SaleBloc>().add(const SaleCartCleared()),
              icon: const Icon(Icons.delete_outline),
              label: Text(context.l10n.clearCart),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                minimumSize: const Size(48, 48),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item, required this.currency});

  final CartItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MoneyText(
                    value: item.product.price,
                    currency: currency,
                    style: theme.textTheme.bodySmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => context.read<SaleBloc>().add(
                    SaleItemQtyChanged(
                      productId: item.product.id,
                      qty: item.qty - 1,
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${item.qty}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
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
              width: 82,
              child: MoneyText(
                value: item.subtotal,
                currency: currency,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTotalBar extends StatelessWidget {
  const _CartTotalBar({required this.state, required this.currency});

  final SaleState state;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          final total = Column(
            crossAxisAlignment: isNarrow
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cartTotal,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              MoneyText(
                value: state.total,
                currency: currency,
                style: theme.textTheme.headlineSmall,
                color: theme.colorScheme.primary,
              ),
            ],
          );
          final checkout = FilledButton.icon(
            onPressed: () => _showPayment(context, state),
            icon: const Icon(Icons.payment),
            label: Text(context.l10n.checkout(state.itemCount)),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [total, const SizedBox(height: 10), checkout],
            );
          }

          return Row(
            children: [
              Expanded(child: total),
              const SizedBox(width: 12),
              checkout,
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
