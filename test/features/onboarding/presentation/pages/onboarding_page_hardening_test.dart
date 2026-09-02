import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/services/store_pin_setup.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

/// Existing live-shop settings that a forced re-onboard must not destroy.
/// Tax id ends in 1 — a real mod-11 checksum pass so `_finish` reaches later
/// validation stages in tests.
final Settings _existing = const Settings().copyWith(
  shopName: 'Old Shop',
  address: '12 Sukhumvit Rd',
  phone: '021234567',
  taxId: '1234567890121',
  currency: r'$',
  vatMode: 'EXCLUSIVE',
  vatRate: 50,
  deviceId: 'device-existing',
  devicePrefix: 'XY',
);

void main() {
  final sl = GetIt.instance;
  late MockSettingsCubit settingsCubit;
  late MockAppLockService mockLock;

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  setUp(() {
    settingsCubit = MockSettingsCubit();
    mockLock = MockAppLockService();
    when(() => settingsCubit.state).thenReturn(
      SettingsState(status: SettingsStatus.loaded, settings: _existing),
    );
    when(() => settingsCubit.saveAndApply(any())).thenAnswer((_) async => true);
    when(() => mockLock.isEnabled()).thenAnswer((_) async => true);
    when(() => mockLock.hasPin()).thenAnswer((_) async => true);
    if (sl.isRegistered<AppLockService>()) {
      sl.unregister<AppLockService>();
    }
    sl.registerSingleton<AppLockService>(mockLock);
  });

  tearDown(() async {
    await settingsCubit.close();
    if (sl.isRegistered<AppLockService>()) {
      sl.unregister<AppLockService>();
    }
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpApp(const OnboardingPage(), settingsCubit: settingsCubit);
  }

  /// Index of the VAT-rate TextField among all alive TextFields. Identified
  /// by its prefilled rate value.
  int indexOfVatField(WidgetTester tester) {
    final fields = find.byType(TextField);
    final prefilled = tester
        .widgetList<TextField>(fields)
        .toList()
        .indexWhere((f) => f.controller?.text == '30');
    expect(prefilled, isNonNegative, reason: 'VAT field not found');
    return prefilled;
  }

  group('onboarding hardening', () {
    testWidgets('prefills shop fields from previously stored settings', (
      tester,
    ) async {
      await pumpPage(tester);

      // Prefilled from _existing settings — never blank after re-onboard.
      // 'Old Shop' appears in both the field and the live receipt preview,
      // hence findsWidgets rather than exactly one.
      expect(find.text('Old Shop'), findsWidgets);
      expect(find.text('12 Sukhumvit Rd'), findsWidgets);
      expect(find.text('021234567'), findsWidgets);
    });

    testWidgets('rejects a VAT rate above the domain max of 30', (
      tester,
    ) async {
      await pumpPage(tester);

      // PageView builds pages lazily — walk to Tax Setup first, then type an
      // out-of-range rate into the prefilled VAT field.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      final vatField = find.byType(TextField).at(indexOfVatField(tester));
      await tester.enterText(vatField, '50');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Selling'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a VAT rate between 0 and 30'), findsOneWidget);
      verifyNever(() => settingsCubit.saveAndApply(any()));
    });

    testWidgets('skip preserves device identity from existing settings', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.tap(find.text('Skip Setup'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => settingsCubit.saveAndApply(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      final saved = captured.single as Settings;
      expect(saved.onboardingCompleted, isTrue);
      expect(saved.deviceId, 'device-existing');
      expect(saved.devicePrefix, 'XY');
      // Existing values survive; nothing is overwritten with blanks.
      expect(saved.shopName, 'Old Shop');
      expect(saved.taxId, _existing.taxId);
    });

    testWidgets('skip keeps the stored tax id when typed value is invalid', (
      tester,
    ) async {
      await pumpPage(tester);

      // The four shop-section fields are built in order:
      // name, address, phone, tax id.
      final taxField = find.byType(TextField).at(3);
      await tester.enterText(taxField, '999');
      await tester.tap(find.text('Skip Setup'));
      await tester.pumpAndSettle();

      final captured = verify(
        () => settingsCubit.saveAndApply(captureAny()),
      ).captured;
      final saved = captured.single as Settings;
      // Invalid checksum input must not replace the stored tax id.
      expect(saved.taxId, _existing.taxId);
    });

    testWidgets('back chevron exposes an accessibility tooltip', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      final backFinder = find.byTooltip('Back');
      expect(backFinder, findsOneWidget);
    });
  });

  group('StorePinSetup trivial-PIN guard (crash regression)', () {
    test('blocks sequential/repeated digits before setPin can throw', () {
      expect(StorePinSetup.validateNewPin('111111', '111111'), 'trivial');
      expect(StorePinSetup.validateNewPin('123456', '123456'), 'trivial');
      expect(StorePinSetup.validateNewPin('000000', '000000'), 'trivial');
    });

    test('still accepts a non-trivial pin and keeps other error codes', () {
      expect(StorePinSetup.validateNewPin('753919', '753919'), isNull);
      expect(StorePinSetup.validateNewPin('753919', '753918'), 'mismatch');
      expect(StorePinSetup.validateNewPin('123', '123'), 'too_short');
    });

    testWidgets('a StateError thrown by setPin shows an error instead of '
        'crashing', (tester) async {
      when(() => mockLock.isEnabled()).thenAnswer((_) async => false);
      when(() => mockLock.hasPin()).thenAnswer((_) async => false);
      when(
        () => mockLock.setPin(any()),
      ).thenThrow(StateError('PIN_TOO_TRIVIAL'));

      await pumpPage(tester);
      await tester.enterText(find.byType(TextField).first, 'Hardened Shop');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Selling'));
      await tester.pumpAndSettle();

      // Create-PIN dialog appears (no stored PIN). Enter a non-trivial pair
      // so the client-side guard passes and setPin itself throws.
      final dialogFields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(dialogFields, findsNWidgets(2));
      await tester.enterText(dialogFields.first, '753919');
      await tester.enterText(dialogFields.last, '753919');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason:
            'StateError from setPin is an Error, not an Exception — '
            'the page must catch it defensively.',
      );
      expect(find.text('Could not enable store PIN'), findsOneWidget);
      verifyNever(() => settingsCubit.saveAndApply(any()));
    });
  });
}
