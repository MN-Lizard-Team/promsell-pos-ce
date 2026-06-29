import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/checkout_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

typedef CheckoutLoadingSetter = void Function(bool loading);

void navigateToCheckout(
  BuildContext context, {
  CheckoutLoadingSetter? onLoadingChange,
}) {
  final l10n = context.l10n;
  final settings = context.read<SettingsCubit>().state.settings;
  final today = DateTime.now().toIso8601String().split('T').first;
  if (settings.dailyCloseLock && settings.lastClosedDate == today) {
    AppSnackBar.error(context, l10n.dayClosedMessage);
    return;
  }

  final cartBloc = context.read<CartBloc>();
  final checkoutBloc = context.read<CheckoutBloc>();
  final settingsCubit = context.read<SettingsCubit>();

  onLoadingChange?.call(true);
  Timer? fallback;
  fallback = Timer(const Duration(seconds: 3), () {
    onLoadingChange?.call(false);
  });

  Navigator.of(context)
      .push(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: cartBloc),
              BlocProvider.value(value: checkoutBloc),
              BlocProvider.value(value: settingsCubit),
            ],
            child: const CheckoutPage(),
          ),
        ),
      )
      .then((_) {
        fallback?.cancel();
        onLoadingChange?.call(false);
      });
}
