import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_business_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_done_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_hero_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_preferences_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_progress_bar.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_settings_sheet.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_shop_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  final String _locale = 'th';
  String _currency = '฿';
  final _currencyCtrl = TextEditingController(text: '฿');
  String _dateFormat = 'dd/MM/yyyy';

  String _vatMode = 'NONE';
  final _vatRateController = TextEditingController(text: '7');

  final _promptPayController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _currencyCtrl.dispose();
    _vatRateController.dispose();
    _promptPayController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final cubit = context.read<SettingsCubit>();
    final current = cubit.state.settings;
    final devicePrefix = _generateDevicePrefix();

    cubit.updateField(
      (_) => current.copyWith(
        shopName: _shopNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        locale: Locale(_locale),
        currency: _currency,
        dateFormat: _dateFormat,
        vatMode: _vatMode,
        vatRate: double.tryParse(_vatRateController.text) ?? 7.0,
        promptpayId:
            Validators.promptpayId(_promptPayController.text.trim()) ?? '',
        onboardingCompleted: true,
        deviceId: IdGenerator.newId(),
        devicePrefix: devicePrefix,
      ),
    );
  }

  String _generateDevicePrefix() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return String.fromCharCodes(
      List.generate(3, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  Future<void> _skip() async {
    final cubit = context.read<SettingsCubit>();
    final current = cubit.state.settings;
    final devicePrefix = _generateDevicePrefix();

    cubit.updateField(
      (_) => current.copyWith(
        locale: Locale(_locale),
        currency: _currency,
        dateFormat: _dateFormat,
        vatMode: 'NONE',
        vatRate: 7.0,
        onboardingCompleted: true,
        deviceId: IdGenerator.newId(),
        devicePrefix: devicePrefix,
      ),
    );
  }

  double _calculateProgress() {
    int filled = 0;
    if (_shopNameController.text.trim().isNotEmpty) filled++;
    if (_currency.isNotEmpty) filled++;
    if (_vatMode != 'NONE' || _vatRateController.text.isNotEmpty) filled++;
    return filled / 3;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (ctx, state) {
        final settings = state.settings;
        final progress = _calculateProgress();
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final accentBrand = colorScheme.primary;
        final scaffoldBg = theme.scaffoldBackgroundColor;
        final cardBg = colorScheme.surface;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () =>
                    OnboardingSettingsSheet.show(ctx, settings, accentBrand),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                OnboardingProgressBar(
                  progress: progress,
                  accentBrand: accentBrand,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OnboardingHeroSection(
                          isDark: isDark,
                          subtitle: ctx.l10n.onboardingWelcomeSubtitle,
                        ),
                        const SizedBox(height: 24),
                        OnboardingShopSection(
                          cardBg: cardBg,
                          accentBrand: accentBrand,
                          shopNameController: _shopNameController,
                          addressController: _addressController,
                          phoneController: _phoneController,
                          currencyController: _currencyCtrl,
                          onCurrencyChanged: (v) => _currency = v,
                        ),
                        const SizedBox(height: 24),
                        OnboardingPreferencesSection(
                          cardBg: cardBg,
                          accentBrand: accentBrand,
                          settings: settings,
                          dateFormat: _dateFormat,
                          onDateFormatChanged: (v) =>
                              setState(() => _dateFormat = v),
                        ),
                        const SizedBox(height: 24),
                        OnboardingBusinessSection(
                          cardBg: cardBg,
                          accentBrand: accentBrand,
                          vatMode: _vatMode,
                          vatRateController: _vatRateController,
                          promptPayController: _promptPayController,
                          onVatModeChanged: (v) => setState(() => _vatMode = v),
                        ),
                        const SizedBox(height: 32),
                        OnboardingDoneSection(
                          cardBg: cardBg,
                          accentBrand: accentBrand,
                          onFinish: _finish,
                          onSkip: _skip,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: _skip,
                            child: Text(ctx.l10n.onboardingSkipSetup),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
