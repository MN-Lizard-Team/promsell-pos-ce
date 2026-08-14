import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/app_lock_settings_page.dart';

import '../../../../helpers/pump_app.dart';

class MockAppLockService extends Mock implements AppLockService {}

void main() {
  late MockAppLockService mockAppLockService;

  setUp(() async {
    await GetIt.I.reset();
    mockAppLockService = MockAppLockService();
    GetIt.I.registerSingleton<AppLockService>(mockAppLockService);
    // V092-B: _refresh() calls isEnabled + hasPin + pinSetAt +
    // getSessionGrace + getLockoutPolicy. Stub defaults so individual
    // tests only override what they care about.
    when(() => mockAppLockService.isEnabled()).thenAnswer((_) async => false);
    when(() => mockAppLockService.hasPin()).thenAnswer((_) async => false);
    when(() => mockAppLockService.pinSetAt()).thenAnswer((_) async => null);
    when(
      () => mockAppLockService.getSessionGrace(),
    ).thenAnswer((_) async => const Duration(minutes: 2));
    when(() => mockAppLockService.getLockoutPolicy()).thenAnswer(
      (_) async =>
          (maxFailedAttempts: 5, baseLockout: const Duration(minutes: 1)),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('AppLockSettingsPage', () {
    testWidgets('shows loading indicator initially', (tester) async {
      // Hold the isEnabled future open so the page stays in the loading state.
      final completer = Completer<bool>();
      when(
        () => mockAppLockService.isEnabled(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpApp(const AppLockSettingsPage());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);

      completer.complete(false);
      await tester.pumpAndSettle();
    });

    testWidgets('shows switch when loaded', (tester) async {
      await tester.pumpApp(const AppLockSettingsPage());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Require store PIN'), findsOneWidget);
    });

    testWidgets('switch is off when lock is disabled', (tester) async {
      await tester.pumpApp(const AppLockSettingsPage());
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchWidget.value, isFalse);
    });
  });
}
