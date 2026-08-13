import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/services/crash_log_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/theme/app_theme.dart';
import 'package:promsell_pos_ce/core/shell/main_shell.dart';
import 'package:promsell_pos_ce/core/widgets/splash/app_splash_wrapper.dart';
import 'package:promsell_pos_ce/features/home/presentation/pages/home_page.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() async {
  await runPromsellApp();
}

Future<void> runPromsellApp({bool configure = true}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (configure) configureDependencies();
  final crashLogService = sl<CrashLogService>();

  FlutterError.onError = (details) {
    AppLogger.error(
      'FlutterError',
      error: details.exception,
      stack: details.stack,
    );
    crashLogService.recordError(
      details.exception,
      details.stack,
      context: 'FlutterError',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('PlatformError', error: error, stack: stack);
    crashLogService.recordError(error, stack, context: 'PlatformError');
    return true;
  };

  final settingsCubit = sl<SettingsCubit>();
  await settingsCubit.load();
  runApp(const PromsellApp());
}

class PromsellApp extends StatelessWidget {
  const PromsellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, curr) =>
            prev.settings.locale != curr.settings.locale ||
            prev.settings.themeMode != curr.settings.themeMode ||
            prev.settings.onboardingCompleted !=
                curr.settings.onboardingCompleted,
        builder: (ctx, state) {
          final showOnboarding = !state.settings.onboardingCompleted;
          return MaterialApp(
            title: 'Promsell POS',
            debugShowCheckedModeBanner: false,
            locale: state.settings.locale,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.settings.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            // Clamp text scaling to 1.3x — POS UI must stay usable on small tablets.
            // Auto-detect RTL from locale for future Arabic/Hebrew support.
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              final clampedScaler = mq.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.3,
              );
              final locale = Localizations.localeOf(context);
              final isRtl = [
                'ar',
                'he',
                'fa',
                'ur',
              ].any((code) => locale.languageCode == code);
              return MediaQuery(
                data: mq.copyWith(textScaler: clampedScaler),
                child: Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                ),
              );
            },
            home: AppSplashWrapper(
              child: showOnboarding
                  ? const OnboardingPage()
                  : const MainShell(),
            ),
            navigatorObservers: [HomePage.routeObserver],
          );
        },
      ),
    );
  }
}
