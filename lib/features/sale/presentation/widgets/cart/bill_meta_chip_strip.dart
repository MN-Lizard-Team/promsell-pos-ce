import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_body.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/customer_selector.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/promotion_selector.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Bill meta as **paper stubs** (ticket language) — not M3 filter pills / mint wash.
class BillMetaChipStrip extends StatelessWidget {
  const BillMetaChipStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enableCartDiscount = context
        .watch<SettingsCubit>()
        .state
        .settings
        .enableCartDiscount;

    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (p, c) =>
          p.customerId != c.customerId ||
          p.promotionId != c.promotionId ||
          p.promotionDiscountAmount != c.promotionDiscountAmount ||
          p.note != c.note ||
          p.hasCartDiscount != c.hasCartDiscount ||
          p.cartDiscountAmount != c.cartDiscountAmount,
      builder: (context, cart) {
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _CustomerChip(cart: cart),
              const SizedBox(width: 6),
              _PromoChip(cart: cart),
              const SizedBox(width: 6),
              _MetaChip(
                icon: cart.note.trim().isEmpty
                    ? Icons.sticky_note_2_outlined
                    : Icons.sticky_note_2,
                label: cart.note.trim().isEmpty
                    ? l10n.saleBillNoteTitle
                    : cart.note.trim(),
                filled: cart.note.trim().isNotEmpty,
                onTap: () => CartReviewBody.showCartNote(context, cart),
              ),
              if (enableCartDiscount) ...[
                const SizedBox(width: 6),
                _MetaChip(
                  icon: Icons.sell_outlined,
                  label: cart.hasCartDiscount
                      ? '-${cart.cartDiscountAmount.value.toStringAsFixed(0)}'
                      : l10n.cartDiscount,
                  filled: cart.hasCartDiscount,
                  onTap: () => CartReviewBody.showCartDiscount(context, cart),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CustomerChip extends StatelessWidget {
  const _CustomerChip({required this.cart});
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<Customer?>(
      future: cart.customerId == null
          ? Future<Customer?>.value(null)
          : sl<CustomerRepository>().getCustomerById(cart.customerId!),
      builder: (context, snap) {
        final name = snap.data?.name;
        final filled = cart.customerId != null;
        return _MetaChip(
          icon: filled ? Icons.person : Icons.person_add_alt_1_outlined,
          label: name ?? (filled ? l10n.customerNotFound : l10n.selectCustomer),
          filled: filled,
          onTap: () => CustomerSelector.openPicker(context),
        );
      },
    );
  }
}

class _PromoChip extends StatelessWidget {
  const _PromoChip({required this.cart});
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<Promotion?>(
      future: cart.promotionId == null
          ? Future<Promotion?>.value(null)
          : sl<PromotionRepository>().getPromotionById(cart.promotionId!),
      builder: (context, snap) {
        final promo = snap.data;
        final filled = cart.promotionId != null;
        final label =
            promo?.name ??
            (filled ? l10n.promotionNotFound : l10n.selectPromotion);
        return _MetaChip(
          icon: filled ? Icons.local_offer : Icons.local_offer_outlined,
          label: label,
          filled: filled,
          onTap: () => PromotionSelector.openPicker(context),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final scheme = theme.colorScheme;
    // Paper stub — stronger border when filled; never primaryContainer mint.
    final borderColor = filled
        ? pos.activeBillRail.withValues(alpha: 0.45)
        : pos.billStubBorder;
    final fg = filled ? scheme.onSurface : scheme.onSurfaceVariant;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: filled ? pos.activeBillRail : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSansThai',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
