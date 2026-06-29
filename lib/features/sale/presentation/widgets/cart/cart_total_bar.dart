import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/checkout_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartTotalBar extends StatelessWidget {
  const CartTotalBar({super.key, required this.state, required this.currency});

  final CartState state;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.totalAmount,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  MoneyText(
                    value: state.total,
                    currency: currency,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'NotoSansThai',
                      fontWeight: FontWeight.w800,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => _showPayment(context, state),
              icon: const Icon(Icons.payment, size: 22),
              label: Text(
                context.l10n.checkout(state.itemCount),
                style: const TextStyle(
                  fontFamily: 'NotoSansThai',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: theme.filledButtonTheme.style?.copyWith(
                minimumSize: const WidgetStatePropertyAll(Size(160, 48)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayment(BuildContext context, CartState state) {
    final settings = context.read<SettingsCubit>().state.settings;
    final today = DateTime.now().toIso8601String().split('T').first;
    if (settings.dailyCloseLock && settings.lastClosedDate == today) {
      AppSnackBar.error(context, context.l10n.dayClosedMessage);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartBloc>()),
            BlocProvider.value(value: context.read<CheckoutBloc>()),
            BlocProvider.value(value: context.read<SettingsCubit>()),
          ],
          child: const CheckoutPage(),
        ),
      ),
    );
  }
}
