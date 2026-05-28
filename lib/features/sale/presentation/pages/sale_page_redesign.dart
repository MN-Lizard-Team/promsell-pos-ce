import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/core/widgets/adaptive_breakpoints.dart';
import 'package:promsell_pos_ce/core/widgets/receipt_preview.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/overlay_toast.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/payment_sheet_redesign.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider(
          create: (_) => sl<SaleBloc>()..add(const SaleDraftInitialized()),
        ),
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

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) =>
          curr.status == ProductStatus.success &&
          prev.products != curr.products,
      listener: (context, state) {
        context.read<SaleBloc>().add(SaleCartProductsRefreshed(state.products));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.salePageTitle),
          actions: [
            BlocBuilder<SaleBloc, SaleState>(
              builder: (ctx, state) => IconButton(
                icon: Badge(
                  isLabelVisible: state.activeDraftId != null,
                  child: const Icon(Icons.bookmarks_outlined),
                ),
                tooltip: ctx.l10n.draftsTitle,
                onPressed: () => _showDraftsSheet(ctx),
              ),
            ),
          ],
        ),
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
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (_, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
        }
      },
      child: Column(
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
                          title: ctx.l10n.noMatchingProducts,
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
                                    mainAxisExtent: isWide ? 148 : 136,
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
        ],
      ),
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
            OverlayToast.show(
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
        final settings = ctx.read<SettingsCubit>().state.settings;
        if (settings.autoPrintPrompt && state.lastSale != null) {
          final sale = state.lastSale!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) _showReceiptDialog(ctx, sale, settings);
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

  void _showReceiptDialog(
    BuildContext context,
    Sale sale,
    AppSettings settings,
  ) {
    final l = context.l10n;
    final labels = ReceiptLabels(
      receipt: l.receiptLabelReceipt,
      payment: l.receiptLabelPayment,
      paymentMethodLabel: localizePaymentMethod(context, sale.paymentMethod),
      total: l.receiptLabelTotal,
      received: l.receiptLabelReceived,
      change: l.receiptLabelChange,
      note: l.receiptLabelNote,
      vat: l.receiptLabelVat,
      vatIncluded: l.receiptLabelVatIncluded(sale.vatRate),
      subtotal: l.receiptLabelSubtotal,
    );
    final vatInfo = sl<ReceiptPdfService>().calculateVat(
      total: sale.totalAmount,
      rate: sale.vatRate,
      mode: sale.vatMode,
    );
    final previewStyle = switch (settings.receiptPreviewStyle) {
      'card' => ReceiptPreviewStyle.card,
      'none' => ReceiptPreviewStyle.none,
      _ => ReceiptPreviewStyle.thermal,
    };
    final showPreview =
        settings.showPostSalePreview && settings.receiptPreviewStyle != 'none';
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          '${l.receiptLabelReceipt} #${sale.receiptNumber ?? sale.id}',
        ),
        content: SingleChildScrollView(
          child: showPreview
              ? ReceiptPreview(
                  settings: settings,
                  labels: labels,
                  style: previewStyle,
                  items: sale.items
                      .map(
                        (i) => ReceiptPreviewItem(
                          name: i.productName,
                          qty: i.qty,
                          price: i.price,
                          subtotal: i.subtotal,
                        ),
                      )
                      .toList(),
                  total: sale.totalAmount,
                  vatInfo: vatInfo,
                  paymentMethod: sale.paymentMethod,
                  amountReceived: sale.amountReceived,
                  changeAmount: sale.changeAmount,
                  note: sale.note,
                  receiptNumber: sale.receiptNumber,
                  createdAt: sale.createdAt,
                )
              : Text(l.saleSavedSuccess),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.print_outlined),
            label: Text(l.printReceipt),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await sl<ReceiptPdfService>().printReceipt(
                sale: sale,
                settings: settings.copyWith(
                  vatRate: sale.vatRate,
                  vatMode: sale.vatMode,
                ),
                labels: labels,
              );
              if (context.mounted) {
                context.read<SaleBloc>().add(const SaleReset());
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: Text(l.shareReceipt),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await sl<ReceiptPdfService>().shareReceipt(
                sale: sale,
                settings: settings.copyWith(
                  vatRate: sale.vatRate,
                  vatMode: sale.vatMode,
                ),
                labels: labels,
              );
              if (context.mounted) {
                context.read<SaleBloc>().add(const SaleReset());
              }
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<SaleBloc>().add(const SaleReset());
            },
            child: Text(l.cancel),
          ),
        ],
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
              onPressed: () => _confirmClearCart(context),
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

  void _confirmClearCart(BuildContext context) {
    final bloc = context.read<SaleBloc>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.clearCart),
        content: Text(context.l10n.confirmClearCart),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              bloc.add(const SaleCartCleared());
              Navigator.pop(dialogCtx);
            },
            child: Text(
              context.l10n.clearCart,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    final atStockLimit =
        item.product.trackStock &&
        !allowOversell &&
        item.qty >= item.product.stock;

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
                  Row(
                    children: [
                      MoneyText(
                        value: item.product.price,
                        currency: currency,
                        style: theme.textTheme.bodySmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      if (item.discountAmount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.discountLabel(
                            item.discountAmount.toStringAsFixed(2),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                item.discountAmount > 0
                    ? Icons.local_offer
                    : Icons.local_offer_outlined,
                size: 18,
                color: item.discountAmount > 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: context.l10n.discountDialogTitle,
              onPressed: () => _showItemDiscountDialog(context, item, currency),
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
                      allowOversell: allowOversell,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32),
                  child: Text(
                    '${item.qty}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: atStockLimit ? context.l10n.stockLimitReached : null,
                  onPressed: atStockLimit
                      ? null
                      : () => context.read<SaleBloc>().add(
                          SaleItemQtyChanged(
                            productId: item.product.id,
                            qty: item.qty + 1,
                            allowOversell: allowOversell,
                          ),
                        ),
                ),
                if (atStockLimit)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 82),
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

          final discountBtn = TextButton.icon(
            onPressed: () => _showCartDiscountDialog(context, state, currency),
            icon: Icon(
              state.hasCartDiscount
                  ? Icons.local_offer
                  : Icons.local_offer_outlined,
              size: 18,
              color: state.hasCartDiscount
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            label: Text(
              state.hasCartDiscount
                  ? '$currency${state.cartDiscountAmount.toStringAsFixed(2)}'
                  : context.l10n.applyCartDiscount,
              style: state.hasCartDiscount
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                discountBtn,
                total,
                const SizedBox(height: 10),
                checkout,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [discountBtn, const Spacer(), checkout]),
              total,
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

void _showItemDiscountDialog(
  BuildContext context,
  CartItem item,
  String currency,
) {
  showDialog(
    context: context,
    builder: (ctx) => _DiscountDialog(
      title: item.product.name,
      currency: currency,
      initialType: item.discountType ?? 'PERCENT',
      initialValue: item.discountValue,
      onApply: (type, value) {
        context.read<SaleBloc>().add(
          SaleItemDiscountChanged(
            productId: item.product.id,
            discountType: type,
            discountValue: value,
          ),
        );
      },
      onClear: item.discountAmount > 0
          ? () => context.read<SaleBloc>().add(
              SaleItemDiscountCleared(item.product.id),
            )
          : null,
    ),
  );
}

void _showCartDiscountDialog(
  BuildContext context,
  SaleState state,
  String currency,
) {
  showDialog(
    context: context,
    builder: (ctx) => _DiscountDialog(
      title: context.l10n.cartDiscount,
      currency: currency,
      initialType: state.cartDiscountType ?? 'PERCENT',
      initialValue: state.cartDiscountValue,
      onApply: (type, value) {
        context.read<SaleBloc>().add(
          SaleCartDiscountChanged(discountType: type, discountValue: value),
        );
      },
      onClear: state.hasCartDiscount
          ? () => context.read<SaleBloc>().add(const SaleCartDiscountCleared())
          : null,
    ),
  );
}

void _showDraftsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: context.read<SaleBloc>(),
      child: const _DraftsBottomSheet(),
    ),
  );
}

class _DraftsBottomSheet extends StatefulWidget {
  const _DraftsBottomSheet();

  @override
  State<_DraftsBottomSheet> createState() => _DraftsBottomSheetState();
}

class _DraftsBottomSheetState extends State<_DraftsBottomSheet> {
  late Future<List<DraftCart>> _draftsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => setState(() {
    _draftsFuture = sl<DraftCartRepository>().listDrafts();
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (prev, curr) => prev.activeDraftId != curr.activeDraftId,
      listener: (ctx, st) => _reload(),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    l10n.draftsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      context.read<SaleBloc>().add(const SaleDraftCreated());
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.newDraft),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<DraftCart>>(
                  future: _draftsFuture,
                  builder: (_, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final drafts = snap.data ?? [];
                    final activeDraftId = context
                        .read<SaleBloc>()
                        .state
                        .activeDraftId;
                    return ListView.builder(
                      controller: scrollCtrl,
                      itemCount: drafts.length,
                      itemBuilder: (_, i) {
                        final draft = drafts[i];
                        final isActive = draft.id == activeDraftId;
                        return _DraftTile(
                          id: draft.id,
                          name: draft.name,
                          itemCount: draft.itemCount,
                          total: draft.total,
                          currency: currency,
                          isActive: isActive,
                          l10n: l10n,
                          theme: theme,
                          onSwitch: isActive
                              ? null
                              : () {
                                  context
                                      .read<SaleBloc>()
                                      .add(SaleDraftSwitched(draft.id));
                                  Navigator.pop(context);
                                },
                          onDelete: drafts.length > 1
                              ? () {
                                  context
                                      .read<SaleBloc>()
                                      .add(SaleDraftDeleted(draft.id));
                                  _reload();
                                }
                              : null,
                          onRename: (name) => context.read<SaleBloc>().add(
                            SaleDraftRenamed(draftId: draft.id, name: name),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}


class _DraftTile extends StatelessWidget {
  const _DraftTile({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.total,
    required this.currency,
    required this.isActive,
    required this.l10n,
    required this.theme,
    required this.onSwitch,
    required this.onDelete,
    required this.onRename,
  });

  final String id;
  final String? name;
  final int itemCount;
  final double total;
  final String currency;
  final bool isActive;
  final dynamic l10n;
  final ThemeData theme;
  final VoidCallback? onSwitch;
  final VoidCallback? onDelete;
  final void Function(String)? onRename;

  @override
  Widget build(BuildContext context) {
    final displayName = name?.isNotEmpty == true ? name! : 'Draft';
    return ListTile(
      leading: Icon(
        Icons.receipt_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      title: Text(
        isActive ? '$displayName (${l10n.activeDraftLabel})' : displayName,
        style: isActive
            ? TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              )
            : null,
      ),
      subtitle: Text('$itemCount items · $currency${total.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRename != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: l10n.renameDraft,
              onPressed: () => _showRenameDialog(context, displayName),
            ),
          if (onDelete != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              tooltip: l10n.deleteDraft,
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      onTap: onSwitch,
    );
  }

  void _showRenameDialog(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.renameDraft),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: context.l10n.draftNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onRename?.call(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteDraft),
        content: Text(context.l10n.deleteDraftConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.deleteDraft),
          ),
        ],
      ),
    );
  }
}

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog({
    required this.title,
    required this.currency,
    required this.initialType,
    required this.onApply,
    this.initialValue,
    this.onClear,
  });

  final String title;
  final String currency;
  final String initialType;
  final double? initialValue;
  final void Function(String type, double value) onApply;
  final VoidCallback? onClear;

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  late String _type;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _ctrl.text = widget.initialValue?.toStringAsFixed(2) ?? '';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final value = double.tryParse(_ctrl.text) ?? 0;

    return AlertDialog(
      title: Text(l10n.discountDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'PERCENT',
                label: Text(l10n.discountTypePercent),
              ),
              ButtonSegment(
                value: 'AMOUNT',
                label: Text(l10n.discountTypeAmount),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _type == 'PERCENT' ? '%' : widget.currency,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (value > 0) ...[
            const SizedBox(height: 8),
            Text(
              l10n.discountPreview(
                '${widget.currency}${value.toStringAsFixed(2)}',
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (widget.onClear != null)
          TextButton(
            onPressed: () {
              widget.onClear!();
              Navigator.pop(context);
            },
            child: Text(
              l10n.discountClear,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: value > 0
              ? () {
                  widget.onApply(_type, value);
                  Navigator.pop(context);
                }
              : null,
          child: Text(l10n.discountApply),
        ),
      ],
    );
  }
}
