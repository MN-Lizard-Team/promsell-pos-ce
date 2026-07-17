import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/sellability_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/summary_widgets.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.product,
    this.category,
    required this.currency,
  });

  final Product product;
  final Category? category;
  final String currency;

  Future<void> _copyBarcode(BuildContext context, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: product.barcode!));
    if (context.mounted) {
      AppSnackBar.info(context, l10n.copyBarcode);
    }
  }

  SellabilityStatus _resolveSellability(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    var threshold = 5;
    try {
      threshold = context
          .read<SettingsCubit>()
          .state
          .settings
          .lowStockThreshold;
    } catch (_) {}
    return resolveSellabilityStatus(
      isActive: product.isActive,
      price: product.price.value,
      trackStock: product.trackStock,
      stock: product.stock,
      lowStockThreshold: threshold,
      l10n: l10n,
      cs: cs,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cs = theme.colorScheme;
    final hasImage =
        (product.imagePath != null && product.imagePath!.isNotEmpty) ||
        (product.imageThumbnailPath != null &&
            product.imageThumbnailPath!.isNotEmpty) ||
        (product.imageUrl != null && product.imageUrl!.isNotEmpty);
    final profit = product.price - product.cost;
    final sellability = _resolveSellability(context);
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = width < 380 ? 120.0 : 136.0;
    final rawUnit = product.unit?.trim() ?? '';
    final unit = rawUnit.isEmpty ? '' : ' $rawUnit';
    final stockValue = product.trackStock
        ? '${CurrencyFormatter.formatQuantityCompact(product.stock)}$unit'
        : l10n.na;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: hasImage,
                  label: hasImage
                      ? l10n.productImageSemantics
                      : l10n.noProductImageSemantics,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasImage
                          ? () => ImageViewerDialog.showSingle(
                              context,
                              ImageViewerDialog.providerFromPaths(
                                imagePath: product.imagePath,
                                imageUrl: product.imageUrl,
                              ),
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      child: ProductAvatar(
                        imagePath: product.imagePath,
                        imageThumbnailPath: product.imageThumbnailPath,
                        imageUrl: product.imageUrl,
                        size: imageSize,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          SummaryChip(
                            label: sellability.label,
                            icon: sellability.icon,
                            color: sellability.color,
                            onColor: sellability.onColor,
                          ),
                          if (product.isRecommended)
                            SummaryChip(
                              label: l10n.productRecommended,
                              icon: Icons.star_rounded,
                              color: cs.tertiaryContainer,
                              onColor: cs.onTertiaryContainer,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          category!.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.skuLabel}: ${product.sku != null && product.sku!.isNotEmpty ? product.sku : l10n.na}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${l10n.barcodeLabel}: ${product.barcode != null && product.barcode!.isNotEmpty ? product.barcode : l10n.na}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.barcode != null &&
                              product.barcode!.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: l10n.copyBarcode,
                              child: InkWell(
                                onTap: () => _copyBarcode(context, l10n),
                                borderRadius: BorderRadius.circular(999),
                                child: Semantics(
                                  button: true,
                                  label: l10n.copyBarcode,
                                  child: SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: Icon(
                                      Icons.copy_outlined,
                                      size: 18,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.retailPrice,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Semantics(
                        label:
                            '${l10n.retailPrice}: $currency${product.price.value.toStringAsFixed(2)}',
                        child: MoneyText(
                          value: product.price.value,
                          currency: currency,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    label: l10n.averageCost,
                    value: CurrencyFormatter.formatCompactWithSymbol(
                      product.cost.value,
                      currency,
                    ),
                    icon: Icons.local_offer_outlined,
                    iconColor: cs.primary,
                    iconBgColor: cs.primaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatItem(
                    label: l10n.averageProfit,
                    value: CurrencyFormatter.formatCompactWithSymbol(
                      profit.value,
                      currency,
                    ),
                    valueColor: cs.tertiary,
                    icon: Icons.paid_outlined,
                    iconColor: cs.tertiary,
                    iconBgColor: cs.tertiaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: StatItem(
                      key: ValueKey('${product.stock}-$unit'),
                      label: l10n.remainingStock,
                      value: stockValue,
                      icon: Icons.inventory_2_outlined,
                      iconColor: cs.secondary,
                      iconBgColor: cs.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
