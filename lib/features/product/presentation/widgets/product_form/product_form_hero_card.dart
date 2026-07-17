import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/stable_listenable_builder.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_pricing_insights.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/sellability_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/summary_widgets.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_hero_image.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Summary under DetailHeader: image, sellability, live name, price/stock metrics.
/// SKU/barcode are edited on Codes only; hero may show a soft "no barcode" chip.
class ProductFormHeroCard extends StatelessWidget {
  const ProductFormHeroCard({
    super.key,
    required this.imagePath,
    required this.imageUrl,
    required this.categoryName,
    required this.isLoading,
    required this.onImageTap,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.costCtrl,
    required this.barcodeCtrl,
    required this.isActive,
    required this.isRecommended,
    required this.trackStock,
    required this.currency,
    required this.onGoToTab,
    this.unitCtrl,
  });

  final String? imagePath;
  final String? imageUrl;
  final String? categoryName;
  final bool isLoading;
  final VoidCallback onImageTap;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController costCtrl;
  final TextEditingController barcodeCtrl;
  final TextEditingController? unitCtrl;
  final bool isActive;
  final bool isRecommended;
  final bool trackStock;
  final String currency;
  final void Function(int tabIndex) onGoToTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final lowStockThreshold = context
        .watch<SettingsCubit>()
        .state
        .settings
        .lowStockThreshold;

    final listenables = <Listenable>[
      nameCtrl,
      priceCtrl,
      stockCtrl,
      costCtrl,
      barcodeCtrl,
      ?unitCtrl,
    ];

    return StableListenableBuilder(
      listenables: listenables,
      builder: (context, _) {
        final priceVal = double.tryParse(priceCtrl.text.trim()) ?? 0;
        final stockVal = int.tryParse(stockCtrl.text.trim()) ?? 0;
        final unit = unitCtrl?.text.trim();
        final noBarcode = barcodeCtrl.text.trim().isEmpty;

        final sellability = resolveSellabilityStatus(
          isActive: isActive,
          price: priceVal,
          trackStock: trackStock,
          stock: stockVal,
          lowStockThreshold: lowStockThreshold,
          l10n: l10n,
          cs: cs,
        );

        final name = nameCtrl.text.trim();
        final width = MediaQuery.sizeOf(context).width;
        final imageSize = width < 380 ? 96.0 : 112.0;

        final sellTab = sellabilityTargetTab(sellability.kind);
        final pricing = ProductPricingInsights.fromText(
          priceText: priceCtrl.text,
          costText: costCtrl.text,
        );
        String? marginLabel;
        if (pricing.hasCost && pricing.marginPct != null) {
          final margin = pricing.marginPct!;
          final sign = margin >= 0 ? '+' : '';
          marginLabel = '$sign${margin.toStringAsFixed(0)}%';
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                label: l10n.imageHelper,
                child: InkWell(
                  key: const ValueKey('product-form-image-action'),
                  onTap: onImageTap,
                  borderRadius: BorderRadius.circular(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: ProductHeroImage(
                        imagePath: imagePath,
                        imageUrl: imageUrl,
                        categoryName: categoryName,
                        isLoading: isLoading,
                        onTap: onImageTap,
                      ),
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
                          onTap: sellTab == null
                              ? null
                              : () => onGoToTab(sellTab),
                        ),
                        if (categoryName != null && categoryName!.isNotEmpty)
                          SummaryChip(
                            label: categoryName!,
                            color: cs.tertiaryContainer,
                            onColor: cs.onTertiaryContainer,
                            onTap: () => onGoToTab(0),
                          ),
                        if (isRecommended)
                          SummaryChip(
                            label: l10n.productRecommended,
                            icon: Icons.star,
                            color: cs.primaryContainer,
                            onColor: cs.onPrimaryContainer,
                            onTap: () => onGoToTab(0),
                          ),
                        if (noBarcode)
                          SummaryChip(
                            label: l10n.heroNoBarcode,
                            icon: Icons.qr_code_2_outlined,
                            color: cs.tertiaryContainer,
                            onColor: cs.onTertiaryContainer,
                            onTap: () => onGoToTab(3),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name.isEmpty ? l10n.addProduct : name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _HeroMetricsRow(
                      currency: currency,
                      price: priceVal,
                      stock: stockVal,
                      trackStock: trackStock,
                      unit: (unit != null && unit.isNotEmpty) ? unit : null,
                      marginLabel: marginLabel,
                      onPriceTap: () => onGoToTab(1),
                      onStockTap: () => onGoToTab(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroMetricsRow extends StatelessWidget {
  const _HeroMetricsRow({
    required this.currency,
    required this.price,
    required this.stock,
    required this.trackStock,
    required this.onPriceTap,
    required this.onStockTap,
    this.unit,
    this.marginLabel,
  });

  final String currency;
  final double price;
  final int stock;
  final bool trackStock;
  final String? unit;
  final String? marginLabel;
  final VoidCallback onPriceTap;
  final VoidCallback onStockTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    final stockText = !trackStock
        ? '—'
        : unit != null
        ? '${CurrencyFormatter.formatGroupedInt(stock)} $unit'
        : l10n.stockLabel(stock);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 4,
      children: [
        InkWell(
          onTap: onPriceTap,
          borderRadius: BorderRadius.circular(4),
          child: price > 0
              ? MoneyText(
                  value: price,
                  currency: currency,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'NotoSansThai',
                  ),
                  color: cs.primary,
                )
              : Text('—', style: muted),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('·', style: muted),
        ),
        InkWell(
          onTap: onStockTap,
          borderRadius: BorderRadius.circular(4),
          child: Text(stockText, style: muted),
        ),
        if (marginLabel != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('·', style: muted),
          ),
          Text(
            marginLabel!,
            style: muted?.copyWith(
              color: marginLabel!.startsWith('-') ? cs.error : cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
