import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleDashboardHeader extends StatelessWidget {
  const SaleDashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final settings = context.watch<SettingsCubit>().state.settings;
    final shopName = settings.shopName;
    final currency = settings.currency;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final cartState = context.select<CartBloc, CartState>((bloc) => bloc.state);

    return StreamBuilder<List<Sale>>(
      stream: sl<SaleRepository>().watchSales(from: todayStart, to: todayEnd),
      builder: (ctx, snapshot) {
        final sales = snapshot.data ?? const [];
        final completed = sales.where((s) => s.status == 'COMPLETED').toList();
        final revenue = completed.fold<double>(
          0,
          (sum, s) => sum + s.totalAmount,
        );
        final salesCount = completed.length;
        final cartCount = cartState.itemCount;
        final cartTotal = cartState.total;

        final revenueStr = revenue.toStringAsFixed(
          revenue == revenue.roundToDouble() ? 0 : 2,
        );
        final cartTotalStr = cartTotal.toStringAsFixed(
          cartTotal == cartTotal.roundToDouble() ? 0 : 2,
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (shopName.isNotEmpty) ...[
                  Icon(
                    Icons.store_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                _statPill(
                  theme,
                  icon: Icons.trending_up_rounded,
                  label: l10n.todayRevenue,
                  value: '$currency$revenueStr',
                  valueColor: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _statPill(
                  theme,
                  icon: Icons.receipt_outlined,
                  label: l10n.todaySalesCount,
                  value: '$salesCount',
                ),
                const SizedBox(width: 8),
                _statPill(
                  theme,
                  icon: Icons.shopping_cart_outlined,
                  label: '$cartCount',
                  value: '$currency$cartTotalStr',
                  valueColor: cartCount > 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statPill(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
