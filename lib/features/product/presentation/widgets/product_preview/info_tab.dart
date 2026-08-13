import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/codes_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({
    super.key,
    required this.product,
    this.category,
    this.onGenerateBarcode,
    this.onGenerateSku,
  });

  final Product product;
  final Category? category;
  final VoidCallback? onGenerateBarcode;
  final VoidCallback? onGenerateSku;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.yMMMd(locale);
    final timeFormat = DateFormat.Hm(locale);
    final description = product.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    final supplier = product.supplier?.trim();
    final hasSupplier = supplier != null && supplier.isNotEmpty;
    final optionGroups = product.optionGroups;

    return ListView(
      padding: productPreviewTabPadding,
      children: [
        PreviewCard(
          title: l10n.productTabInfo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoListItem(
                icon: TablerIcons.category,
                label: l10n.categoryLabel,
                value: Text(category?.name ?? l10n.noCategory),
              ),
              if (product.brand != null && product.brand!.trim().isNotEmpty)
                InfoListItem(
                  icon: TablerIcons.building,
                  label: l10n.productBrandLabel,
                  value: Text(product.brand!.trim()),
                ),
              if (hasSupplier)
                InfoListItem(
                  icon: TablerIcons.truck,
                  label: l10n.productSupplierLabel,
                  value: Text(supplier),
                ),
              InfoListItem(
                icon: TablerIcons.rulerMeasure,
                label: l10n.productUnitLabel,
                value: Text(
                  product.unit?.trim().isNotEmpty == true
                      ? product.unit!.trim()
                      : l10n.productUnitDefault,
                ),
              ),
              InfoListItem(
                icon: product.isActive ? TablerIcons.eye : TablerIcons.eyeOff,
                label: l10n.productPreviewStatus,
                value: Text(
                  product.isActive
                      ? l10n.productSettingsOutcomeVisible
                      : l10n.productSettingsOutcomeHidden,
                ),
                valueColor: product.isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
              InfoListItem(
                icon: product.isRecommended
                    ? TablerIcons.starFilled
                    : TablerIcons.star,
                label: l10n.productRecommended,
                value: Text(
                  product.isRecommended
                      ? l10n.productSettingsOutcomeRecommended
                      : l10n.productSettingsOutcomeNotRecommended,
                ),
                valueColor: product.isRecommended
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              InfoListItem(
                icon: TablerIcons.calendar,
                label: l10n.dateCreated,
                value: Text(
                  '${dateFormat.format(product.createdAt)} ${timeFormat.format(product.createdAt)}',
                ),
              ),
              InfoListItem(
                icon: TablerIcons.clock,
                label: l10n.dateUpdated,
                value: Text(
                  '${dateFormat.format(product.updatedAt)} ${timeFormat.format(product.updatedAt)}',
                ),
              ),
              InfoListItem(
                icon: TablerIcons.notes,
                label: l10n.productDescriptionLabel,
                value: Text(
                  hasDescription ? description : l10n.productDescriptionEmpty,
                  maxLines: hasDescription ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                valueColor: hasDescription
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        if (optionGroups.isNotEmpty) ...[
          const SizedBox(height: 16),
          PreviewCard(
            title: l10n.productOptionsSummaryTitle,
            child: Column(
              children: [
                for (var i = 0; i < optionGroups.length; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  InfoListItem(
                    icon: TablerIcons.adjustments,
                    label: optionGroups[i].name,
                    value: Text(_optionGroupDetail(context, optionGroups[i])),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        CodesCard(
          product: product,
          onGenerateBarcode: onGenerateBarcode,
          onGenerateSku: onGenerateSku,
        ),
      ],
    );
  }

  String _optionGroupDetail(BuildContext context, ProductOptionGroup group) {
    final l10n = context.l10n;
    final mode = group.selectionType == OptionSelectionType.multiple
        ? l10n.optionSelectionMultiple
        : l10n.optionSelectionSingle;
    final required = group.isRequired ? '${l10n.optionRequired} · ' : '';
    // Label already shows group name; value is mode + count only.
    return '$required$mode · ${group.options.length}';
  }
}
