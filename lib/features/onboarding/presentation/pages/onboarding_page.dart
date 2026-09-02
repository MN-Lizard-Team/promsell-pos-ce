import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_bottom_bar.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_business_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_done_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_hero_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_preferences_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_progress_bar.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_settings_sheet.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_shop_section.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController(initialPage: 0);
  int _currentStep = 0;
  bool _heroDismissed = false;
  bool _isCompleting = false;
  static const _totalSteps = 4;

  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _currencyCtrl = TextEditingController(text: '฿');
  final _vatRateController = TextEditingController(text: '7');
  final _promptPayController = TextEditingController();
  final _shopNameFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _taxIdFocus = FocusNode();
  final _vatRateFocus = FocusNode();
  final _promptPayFocus = FocusNode();

  String _dateFormat = 'dd/MM/yyyy';
  String _vatMode = 'NONE';
  bool _storePinEnabled = false;

  @override
  void initState() {
    super.initState();
    // Prefill from any previously stored settings so a forced re-onboard
    // (upgrade seed or old-backup restore) never blanks out live shop data.
    final settings = context.read<SettingsCubit>().state.settings;
    if (_shopNameController.text.isEmpty && settings.shopName.isNotEmpty) {
      _shopNameController.text = settings.shopName;
    }
    if (_addressController.text.isEmpty && settings.address.isNotEmpty) {
      _addressController.text = settings.address;
    }
    if (_phoneController.text.isEmpty && settings.phone.isNotEmpty) {
      _phoneController.text = settings.phone;
    }
    if (_taxIdController.text.isEmpty && settings.taxId.isNotEmpty) {
      _taxIdController.text = settings.taxId;
    }
    if (settings.currency.isNotEmpty) _currencyCtrl.text = settings.currency;
    _vatRateController.text = settings.vatRate.toStringAsFixed(0);
    _vatMode = settings.vatMode;
    if (settings.promptpayId.isNotEmpty) {
      _promptPayController.text = settings.promptpayId;
    }
    _dateFormat = settings.dateFormat;
    _loadStorePinState();
  }

  Future<void> _loadStorePinState() async {
    if (!sl.isRegistered<AppLockService>()) return;
    final enabled = await sl<AppLockService>().isEnabled();
    if (mounted) setState(() => _storePinEnabled = enabled);
  }

  void _setPinEnabled(bool enabled) {
    if (mounted) setState(() => _storePinEnabled = enabled);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxIdController.dispose();
    _currencyCtrl.dispose();
    _vatRateController.dispose();
    _promptPayController.dispose();
    _shopNameFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    _taxIdFocus.dispose();
    _vatRateFocus.dispose();
    _promptPayFocus.dispose();
    super.dispose();
  }

  Future<bool> _ensureStorePinBeforeComplete() async {
    final lock = sl<AppLockService>();
    final enabled = await lock.isEnabled();
    final hasPin = await lock.hasPin();

    // Case 1: lock already on with a PIN — nothing to do.
    if (enabled && hasPin) {
      _setPinEnabled(true);
      return true;
    }

    // Case 2: PIN hash exists but lock is disabled — just re-enable.
    // No need to ask for a new PIN; the stored PIN is still valid.
    if (hasPin && !enabled) {
      try {
        await lock.enable();
        _setPinEnabled(true);
        return true;
      } on Exception catch (e) {
        AppLogger.error('Onboarding enable failed', error: e);
        if (mounted) {
          AppSnackBar.error(context, context.l10n.appLockEnableFailed);
        }
        return false;
      }
    }

    // Case 3: no PIN stored — ask the user to create one, with option to skip.
    if (!mounted) return false;
    final result = await showCreateStorePinDialog(context, allowSkip: true);
    if (!mounted) return false;

    if (result.isCreated && result.pin != null) {
      try {
        await lock.setPin(result.pin!);
        _setPinEnabled(true);
        return true;
      }
      // StateError (e.g. PIN_TOO_TRIVIAL / PIN_ALREADY_SET) is an Error, not
      // an Exception — catch everything so a rejected PIN can never crash.
      catch (e, stack) {
        AppLogger.error('Onboarding setPin failed', error: e, stack: stack);
        if (mounted) {
          AppSnackBar.error(context, context.l10n.appLockEnableFailed);
        }
        return false;
      }
    }

    if (result.isSkipped) {
      // Confirm the user understands the risk of not using a PIN.
      final confirmed = await _confirmSkipPin();
      if (confirmed) _setPinEnabled(false);
      if (confirmed && mounted) {
        AppSnackBar.warning(context, context.l10n.onboardingPinSkippedHint);
      }
      return confirmed;
    }

    // cancelled
    return false;
  }

  Future<bool> _confirmSkipPin() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.onboardingSkipPinConfirmTitle),
        content: Text(l10n.onboardingSkipPinConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.onboardingSetupPinInstead),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.onboardingConfirmSkipPin),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _finish() async {
    if (_isCompleting) return;
    if (_shopNameController.text.trim().isEmpty) {
      AppSnackBar.error(context, context.l10n.shopNameRequired);
      return;
    }
    final rawTaxId = _taxIdController.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .trim();
    if (rawTaxId.isNotEmpty) {
      try {
        Validators.thaiTaxId(rawTaxId);
      } on ArgumentError {
        AppSnackBar.error(context, context.l10n.taxIdChecksumInvalid);
        return;
      }
    }

    // Mirror TaxConfig's own range so validation can never pass a value the
    // domain will silently clamp (NaN fails both comparisons).
    final parsedVatRate = double.tryParse(
      _vatRateController.text.trim().replaceAll(',', '.'),
    );
    if (_vatMode != 'NONE' &&
        (parsedVatRate == null ||
            parsedVatRate.isNaN ||
            parsedVatRate < TaxConfig.minVatRate ||
            parsedVatRate > TaxConfig.maxVatRate)) {
      AppSnackBar.error(context, context.l10n.onboardingInvalidVatRate);
      return;
    }

    String? promptpayId;
    try {
      promptpayId = Validators.promptpayId(_promptPayController.text.trim());
    } on ArgumentError {
      if (mounted) {
        AppSnackBar.error(context, context.l10n.promptpayInvalidId);
      }
      return;
    }

    // PIN gate runs last: never create a PIN before every field validates.
    if (!await _ensureStorePinBeforeComplete()) return;
    if (!mounted) return;

    _isCompleting = true;
    try {
      final cubit = context.read<SettingsCubit>();
      final current = cubit.state.settings;

      final saved = await cubit.saveAndApply(
        current.copyWith(
          shopName: _shopNameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          taxId: rawTaxId,
          localeCode: current.localeCode,
          currency: _currencyCtrl.text.trim(),
          dateFormat: _dateFormat,
          vatMode: _vatMode,
          vatRate: parsedVatRate ?? 7.0,
          promptpayId: promptpayId ?? '',
          onboardingCompleted: true,
          deviceId: current.deviceId.isEmpty
              ? IdGenerator.newId()
              : current.deviceId,
          devicePrefix: current.devicePrefix.isEmpty
              ? _generateDevicePrefix()
              : current.devicePrefix,
        ),
      );
      if (!saved && mounted) {
        AppSnackBar.error(context, context.l10n.unexpectedError);
      }
    } finally {
      _isCompleting = false;
    }
  }

  /// Two uppercase alphanumeric chars from a secure RNG — matches the format
  /// documented for `{YYMMDD}-{prefix}-{seq}` receipt numbers and the
  /// fallback generator in [ReceiptNumberService].
  String _generateDevicePrefix() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return String.fromCharCodes(
      List.generate(2, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  Future<void> _skip() async {
    if (_isCompleting) return;
    if (!await _ensureStorePinBeforeComplete()) return;
    if (!mounted) return;

    _isCompleting = true;
    try {
      final cubit = context.read<SettingsCubit>();
      final current = cubit.state.settings;

      // Skip is lenient but not reckless: keep previously stored values when
      // the typed value is blank/invalid instead of writing garbage.
      final rawTaxId = _taxIdController.text
          .replaceAll(RegExp(r'[^0-9]'), '')
          .trim();
      var taxIdValid = true;
      if (rawTaxId.isNotEmpty) {
        try {
          Validators.thaiTaxId(rawTaxId);
        } on ArgumentError {
          taxIdValid = false;
        }
      }
      final parsedVatRate = double.tryParse(
        _vatRateController.text.replaceAll(',', '.'),
      );
      final vatRate =
          (parsedVatRate == null ||
              parsedVatRate.isNaN ||
              parsedVatRate < TaxConfig.minVatRate ||
              parsedVatRate > TaxConfig.maxVatRate)
          ? current.vatRate
          : parsedVatRate;
      String? promptpayId;
      try {
        promptpayId = Validators.promptpayId(_promptPayController.text.trim());
      } on ArgumentError {
        promptpayId = null;
      }

      final saved = await cubit.saveAndApply(
        current.copyWith(
          shopName: _shopNameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          taxId: taxIdValid ? rawTaxId : current.taxId,
          localeCode: current.localeCode,
          currency: _currencyCtrl.text.trim(),
          dateFormat: _dateFormat,
          vatMode: _vatMode,
          vatRate: vatRate,
          promptpayId: promptpayId ?? current.promptpayId,
          onboardingCompleted: true,
          deviceId: current.deviceId.isEmpty
              ? IdGenerator.newId()
              : current.deviceId,
          devicePrefix: current.devicePrefix.isEmpty
              ? _generateDevicePrefix()
              : current.devicePrefix,
        ),
      );
      if (!saved && mounted) {
        AppSnackBar.error(context, context.l10n.unexpectedError);
      }
    } finally {
      _isCompleting = false;
    }
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _pageController.jumpToPage(step);
      return;
    }
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _vatLabelFor(AppLocalizations l10n, String mode) => switch (mode) {
    'INCLUSIVE' => l10n.onboardingInclusive,
    'EXCLUSIVE' => l10n.onboardingExclusive,
    _ => l10n.onboardingNone,
  };

  String _currencyLabelFor(AppLocalizations l10n, String symbol) =>
      switch (symbol) {
        '฿' => l10n.onboardingCurrencyBaht,
        r'$' => l10n.onboardingCurrencyUsd,
        '€' => l10n.onboardingCurrencyEur,
        '¥' => l10n.onboardingCurrencyJpy,
        _ => symbol,
      };

  String _stepLabelFor(BuildContext context, int step) {
    final l10n = context.l10n;
    return switch (step) {
      0 => l10n.onboardingShopInfo,
      1 => l10n.onboardingLocaleCurrency,
      2 => l10n.onboardingTaxSetup,
      _ => l10n.onboardingDone,
    };
  }

  void _onNext() {
    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _finish();
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) => prev.settings != curr.settings,
      builder: (ctx, state) {
        final settings = state.settings;
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final accentBrand = colorScheme.primary;
        final scaffoldBg = theme.scaffoldBackgroundColor;
        final cardBg = theme.cardTheme.color ?? colorScheme.surface;
        final horizontalPadding = MediaQuery.sizeOf(ctx).width < 360
            ? 16.0
            : 24.0;

        final stepLabel = _stepLabelFor(ctx, _currentStep);
        final stepOfLabel = ctx.l10n.onboardingStepOf(
          _currentStep + 1,
          _totalSteps,
        );
        final l10n = ctx.l10n;
        final vatBaseLabel = _vatLabelFor(l10n, _vatMode);
        final parsedSummaryRate = double.tryParse(
          _vatRateController.text.trim().replaceAll(',', '.'),
        );
        final vatLabel = _vatMode == 'NONE' || parsedSummaryRate == null
            ? vatBaseLabel
            : '$vatBaseLabel (${parsedSummaryRate.toStringAsFixed(0)}%)';
        final currencyLabel = _currencyLabelFor(
          l10n,
          _currencyCtrl.text.trim(),
        );

        return PopScope(
          canPop: _currentStep == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onBack();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: scaffoldBg,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      0,
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => OnboardingSettingsSheet.show(
                            ctx,
                            settings,
                            accentBrand,
                          ),
                          icon: const Icon(TablerIcons.adjustments, size: 18),
                          label: Text(ctx.l10n.settingsTitle),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OnboardingProgressBar(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                    accentBrand: accentBrand,
                    stepLabel: stepLabel,
                    stepOfLabel: stepOfLabel,
                    horizontalPadding: horizontalPadding,
                    disableAnimations:
                        MediaQuery.maybeDisableAnimationsOf(ctx) ?? false,
                  ),
                  AnimatedSize(
                    duration:
                        (MediaQuery.maybeDisableAnimationsOf(ctx) ?? false)
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: ClipRect(
                      child: _currentStep == 0 && !_heroDismissed
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: OnboardingHeroSection(
                                isDark: isDark,
                                subtitle: ctx.l10n.onboardingWelcomeSubtitle,
                                onDismiss: () =>
                                    setState(() => _heroDismissed = true),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ),
                  if (_currentStep == 0 && !_heroDismissed)
                    const SizedBox(height: 12),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentStep = i),
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: OnboardingShopSection(
                            cardBg: cardBg,
                            accentBrand: accentBrand,
                            shopNameController: _shopNameController,
                            addressController: _addressController,
                            phoneController: _phoneController,
                            taxIdController: _taxIdController,
                            shopNameFocus: _shopNameFocus,
                            addressFocus: _addressFocus,
                            phoneFocus: _phoneFocus,
                            taxIdFocus: _taxIdFocus,
                            onChanged: () => setState(() {}),
                          ),
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: OnboardingPreferencesSection(
                            cardBg: cardBg,
                            accentBrand: accentBrand,
                            settings: settings,
                            currencyController: _currencyCtrl,
                            dateFormat: _dateFormat,
                            onCurrencyChanged: (_) => setState(() {}),
                            onDateFormatChanged: (v) =>
                                setState(() => _dateFormat = v),
                          ),
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: OnboardingBusinessSection(
                            cardBg: cardBg,
                            accentBrand: accentBrand,
                            vatMode: _vatMode,
                            vatRateController: _vatRateController,
                            promptPayController: _promptPayController,
                            vatRateFocus: _vatRateFocus,
                            promptPayFocus: _promptPayFocus,
                            onVatModeChanged: (v) =>
                                setState(() => _vatMode = v),
                          ),
                        ),
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: OnboardingDoneSection(
                            cardBg: cardBg,
                            accentBrand: accentBrand,
                            onFinish: _finish,
                            onSkip: _skip,
                            shopName: _shopNameController.text.trim(),
                            currencyLabel: currencyLabel,
                            vatLabel: vatLabel,
                            pinProtected: _storePinEnabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: OnboardingBottomBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
              onNext: _onNext,
              onBack: _onBack,
              onSkip: _skip,
              isLastStep: _currentStep == _totalSteps - 1,
            ),
          ),
        );
      },
    );
  }
}
