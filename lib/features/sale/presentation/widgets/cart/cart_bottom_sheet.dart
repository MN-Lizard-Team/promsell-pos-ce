import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_content.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartBottomSheet {
  CartBottomSheet._();

  static void show(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.read<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final cartBloc = context.read<CartBloc>();
    final checkoutBloc = context.read<CheckoutBloc>();
    final draftBloc = context.read<DraftBloc>();
    final settingsCubit = context.read<SettingsCubit>();

    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: false,
      backgroundColor: theme.colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height - mediaQuery.padding.top,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cartBloc),
            BlocProvider.value(value: checkoutBloc),
            BlocProvider.value(value: draftBloc),
            BlocProvider.value(value: settingsCubit),
          ],
          child: _SnapDraggableSheet(currency: currency, settings: settings),
        );
      },
    );
  }
}

class _SnapDraggableSheet extends StatelessWidget {
  const _SnapDraggableSheet({required this.currency, required this.settings});

  final String currency;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.4, 0.6, 0.95],
      builder: (sheetCtx, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: CartContent(
            expanded: false,
            currency: currency,
            settings: settings,
            scrollController: scrollController,
          ),
        );
      },
    );
  }
}
