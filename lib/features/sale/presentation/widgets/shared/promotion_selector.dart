import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Cart/checkout control to attach or clear an active promotion.
class PromotionSelector extends StatelessWidget {
  const PromotionSelector({super.key, this.dense = false});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (p, c) =>
          p.promotionId != c.promotionId ||
          p.promotionDiscountAmount != c.promotionDiscountAmount,
      builder: (context, cart) {
        return FutureBuilder<Promotion?>(
          future: cart.promotionId == null
              ? Future<Promotion?>.value(null)
              : sl<PromotionRepository>().getPromotionById(cart.promotionId!),
          builder: (context, snap) {
            final promo = snap.data;
            final label =
                promo?.name ??
                (cart.promotionId != null
                    ? context.l10n.promotionNotFound
                    : context.l10n.selectPromotion);
            final hasDiscount = cart.promotionDiscountAmount > 0;

            return ListTile(
              contentPadding: dense
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              leading: Icon(
                cart.promotionId == null
                    ? Icons.local_offer_outlined
                    : Icons.local_offer,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: hasDiscount
                  ? Row(
                      children: [
                        Text(
                          '${context.l10n.receiptLabelPromotionDiscount}: ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        MoneyText(
                          value: cart.promotionDiscountAmount,
                          currency: currency,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                  : (promo != null
                        ? Text(
                            _promoValueLabel(context, promo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cart.promotionId != null)
                    IconButton(
                      tooltip: context.l10n.clearPromotion,
                      icon: const Icon(Icons.close),
                      onPressed: () => context.read<CartBloc>().add(
                        const CartPromotionSet(null),
                      ),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => openPicker(context),
            );
          },
        );
      },
    );
  }

  String _promoValueLabel(BuildContext context, Promotion promo) {
    final l10n = context.l10n;
    if (promo.type == PromotionType.percent) {
      return l10n.promotionPercentOff(promo.value.toStringAsFixed(0));
    }
    return l10n.promotionAmountOff(promo.value.toStringAsFixed(2));
  }

  /// Opens promotion picker (dense selector + bill meta chips).
  static Future<void> openPicker(BuildContext context) async {
    final cartBloc = context.read<CartBloc>();
    final selectedId = cartBloc.state.promotionId;
    final promos = await sl<PromotionRepository>().getActivePromotions();
    if (!context.mounted) return;

    final picked = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) =>
          _PromotionPickerSheet(promotions: promos, selectedId: selectedId),
    );

    if (!context.mounted) return;
    // Sheet returns id, '' for clear, or null if dismissed without change.
    if (picked == null) return;
    cartBloc.add(CartPromotionSet(picked.isEmpty ? null : picked));
  }
}

class _PromotionPickerSheet extends StatelessWidget {
  const _PromotionPickerSheet({required this.promotions, this.selectedId});

  final List<Promotion> promotions;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final height = MediaQuery.sizeOf(context).height * 0.65;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.selectPromotion,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selectedId != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: Text(l10n.clearPromotion),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: promotions.isEmpty
                ? Center(child: Text(l10n.noActivePromotions))
                : ListView.separated(
                    itemCount: promotions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = promotions[i];
                      final selected = p.id == selectedId;
                      final valueLabel = p.type == PromotionType.percent
                          ? l10n.promotionPercentOff(p.value.toStringAsFixed(0))
                          : l10n.promotionAmountOff(p.value.toStringAsFixed(2));
                      return ListTile(
                        selected: selected,
                        leading: Icon(
                          selected
                              ? Icons.local_offer
                              : Icons.local_offer_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(p.name),
                        subtitle: Text(valueLabel),
                        trailing: selected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, p.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
