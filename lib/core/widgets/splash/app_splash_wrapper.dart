import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/widgets/splash/app_splash_screen.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class AppSplashWrapper extends StatelessWidget {
  const AppSplashWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        final isLoading =
            state.status == SettingsStatus.loading ||
            state.status == SettingsStatus.initial;
        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 400),
          crossFadeState: isLoading
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: const AppSplashScreen(),
          secondChild: child,
          layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
            return Stack(
              children: [
                Positioned.fill(key: bottomKey, child: bottomChild),
                Positioned.fill(key: topKey, child: topChild),
              ],
            );
          },
        );
      },
    );
  }
}
