import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CompactCartFab extends StatefulWidget {
  const CompactCartFab({super.key});

  @override
  State<CompactCartFab> createState() => _CompactCartFabState();
}

class _CompactCartFabState extends State<CompactCartFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Positioned(
      bottom: 16 + MediaQuery.paddingOf(context).bottom,
      right: 16,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (ctx, state) {
          final count = state.itemCount;
          final total = state.total;

          return TweenAnimationBuilder<double>(
            key: ValueKey('fab_bounce_$count'),
            tween: Tween(begin: 1.15, end: 1.0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: AnimatedBuilder(
              animation: _pressController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 - (_pressController.value * 0.06),
                  child: child,
                );
              },
              child: Material(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                elevation: 6,
                shadowColor: theme.colorScheme.shadow,
                child: GestureDetector(
                  onTapDown: (_) => _pressController.forward(),
                  onTapUp: (_) {
                    _pressController.reverse();
                    CartBottomSheet.show(ctx);
                  },
                  onTapCancel: () => _pressController.reverse(),
                  onLongPress: () {
                    final l10n = ctx.l10n;
                    showDialog(
                      context: ctx,
                      builder: (dialogCtx) => AlertDialog(
                        title: Text(l10n.exitCompactMode),
                        content: Text(l10n.exitCompactModeConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: Text(l10n.cancel),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              final cubit = ctx.read<SettingsCubit>();
                              cubit.update(
                                cubit.state.settings.copyWith(
                                  cartCompactMode: false,
                                  ultraCompactMode: false,
                                ),
                              );
                            },
                            child: Text(l10n.confirm),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: count > 0 ? 68 : 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: theme.colorScheme.onPrimary,
                              size: 24,
                            ),
                            if (count > 0) ...[
                              const SizedBox(height: 2),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  '$currency${total.toStringAsFixed(0)}',
                                  key: ValueKey(total),
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (count > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey('badge_pulse_$count'),
                              tween: Tween(begin: 1.4, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: theme.colorScheme.onError,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
