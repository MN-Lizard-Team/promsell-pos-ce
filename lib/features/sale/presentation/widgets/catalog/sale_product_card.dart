import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
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
    final cartQty = context.select<CartBloc, int>(
      (bloc) => bloc.state.items
          .where((item) => item.product.id == product.id)
          .fold(0, (sum, item) => sum + item.qty),
    );
    final outOfStock = product.trackStock && product.stock == 0;
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    final canTap = !outOfStock || allowOversell;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: cartQty > 0 ? 2 : 0,
      child: Opacity(
        opacity: outOfStock && !allowOversell ? 0.4 : 1.0,
        child: InkWell(
          onTap: canTap
              ? () {
                  HapticFeedback.selectionClick();
                  context.read<CartBloc>().add(
                    CartProductAdded(product, allowOversell: allowOversell),
                  );
                  if (cartQty == 0) {
                    AppSnackBar.info(
                      context,
                      context.l10n.productAddedToCart(product.name),
                    );
                  }
                }
              : null,
          onLongPress: canTap
              ? () => _showQtyDialog(context, product, cartQty)
              : null,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ProductAvatar(
                        imagePath: product.imagePath,
                        imageThumbnailPath: product.imageThumbnailPath,
                        imageUrl: product.imageUrl,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CategoryNameText(
                      categoryId: product.categoryId,
                      noCategory: context.l10n.noCategory,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          product.trackStock
                              ? product.stock == 0
                                    ? context.l10n.outOfStock
                                    : context.l10n.stockLabel(product.stock)
                              : '\u221e',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: product.trackStock && product.stock == 0
                                ? theme.colorScheme.error
                                : product.trackStock && product.stock <= 5
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (cartQty > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Badge(
                    label: Text('$cartQty'),
                    backgroundColor: theme.colorScheme.primary,
                    textColor: theme.colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQtyDialog(BuildContext context, Product product, int currentQty) {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>().state.settings;
    final allowOversell = settings.allowOversell;
    final saleBloc = context.read<CartBloc>();
    final snackCtx = context;
    showDialog(
      context: context,
      builder: (dialogCtx) => _QtyDialog(
        product: product,
        allowOversell: allowOversell,
        onSaved: (qty) {
          saleBloc.add(
            CartProductAdded(product, qty: qty, allowOversell: allowOversell),
          );
          AppSnackBar.info(snackCtx, l10n.productAddedToCart(product.name));
        },
      ),
    );
  }
}

class _QtyDialog extends StatefulWidget {
  const _QtyDialog({
    required this.product,
    required this.allowOversell,
    required this.onSaved,
  });

  final Product product;
  final bool allowOversell;
  final ValueChanged<int> onSaved;

  @override
  State<_QtyDialog> createState() => _QtyDialogState();
}

class _QtyDialogState extends State<_QtyDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final qty = int.tryParse(_ctrl.text);
    if (qty == null || qty <= 0) {
      Navigator.pop(context);
      return;
    }
    var clamped = qty;
    if (widget.product.trackStock && !widget.allowOversell) {
      clamped = qty.clamp(1, widget.product.stock);
    }
    Navigator.pop(context);
    widget.onSaved(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.product.name),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(
          labelText: l10n.quantityLabel,
          suffixText: widget.product.trackStock
              ? l10n.stockLabel(widget.product.stock)
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

class _CategoryNameText extends StatelessWidget {
  const _CategoryNameText({this.categoryId, required this.noCategory});
  final String? categoryId;
  final String noCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (categoryId == null || categoryId!.isEmpty) {
      return Text(
        noCategory,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.secondary,
        ),
      );
    }
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (_, state) {
        final cat = state.categories
            .where((c) => c.id == categoryId)
            .firstOrNull;
        final name = cat?.name ?? categoryId!;
        final catColor = parseCategoryColor(cat?.color);
        final catIcon = parseCategoryIcon(cat?.iconName);
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(catIcon, size: 10, color: catColor),
            ),
            const SizedBox(width: 4),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
