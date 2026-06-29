import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/cart_review_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartBottomBar extends StatefulWidget {
  const CartBottomBar({super.key});

  @override
  State<CartBottomBar> createState() => _CartBottomBarState();
}

class _CartBottomBarState extends State<CartBottomBar>
    with SingleTickerProviderStateMixin {
  bool _bounce = false;

  void _triggerBounce() {
    if (!mounted) return;
    setState(() => _bounce = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _bounce = false);
    });
  }

  void _navigateToCart(BuildContext context) {
    final cartBloc = context.read<CartBloc>();
    final checkoutBloc = context.read<CheckoutBloc>();
    final draftBloc = context.read<DraftBloc>();
    final settingsCubit = context.read<SettingsCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cartBloc),
            BlocProvider.value(value: checkoutBloc),
            BlocProvider.value(value: draftBloc),
            BlocProvider.value(value: settingsCubit),
          ],
          child: const CartReviewPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) => prev.itemCount != curr.itemCount,
      listener: (context, state) => _triggerBounce(),
      child: BlocBuilder<CartBloc, CartState>(
        buildWhen: (prev, curr) =>
            prev.itemCount != curr.itemCount || prev.total != curr.total,
        builder: (ctx, state) {
          final count = state.itemCount;
          final isEmpty = count == 0;

          return Material(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: isEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        key: const ValueKey('empty'),
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              context.l10n.tapProductToAdd,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: ValueKey('cart-$count'),
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _navigateToCart(ctx);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  AnimatedScale(
                                    scale: _bounce ? 1.3 : 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        transitionBuilder: (child, anim) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.5),
                                              end: Offset.zero,
                                            ).animate(anim),
                                            child: FadeTransition(
                                              opacity: anim,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          '$count',
                                          key: ValueKey(count),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.l10n.totalAmount,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        MoneyText(
                                          value: state.total,
                                          currency: currency,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => navigateToCheckout(ctx),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.payment, size: 20),
                            label: Text(
                              context.l10n.checkout(count),
                              style: const TextStyle(
                                fontFamily: 'NotoSansThai',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
