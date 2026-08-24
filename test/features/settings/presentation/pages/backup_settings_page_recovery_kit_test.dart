import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/database/recovery_kit_service.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

class MockRecoveryKitService extends Mock implements RecoveryKitService {}

/// Serves a canned [FilePickerResult] without touching platform channels.
///
/// Must `extend` (not `implement`) the platform interface — platform
/// interface token verification rejects foreign implementations.
class _FakeFilePickerPlatform extends FilePickerPlatform {
  FilePickerResult? result;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
    AndroidSAFOptions? androidSafOptions,
  }) async => result;
}

void main() {
  late MockAppLockService mockAppLockService;
  late MockRecoveryKitService mockRecoveryKitService;
  late MockSettingsCubit mockSettingsCubit;
  late AppLocalizations l10n;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await GetIt.I.reset();
    mockAppLockService = MockAppLockService();
    when(() => mockAppLockService.isEnabled()).thenAnswer((_) async => false);
    GetIt.I.registerSingleton<AppLockService>(mockAppLockService);

    mockRecoveryKitService = MockRecoveryKitService();
    GetIt.I.registerSingleton<RecoveryKitService>(mockRecoveryKitService);

    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    // The recovery kit section sits at the end of a lazy ListView, and the
    // success toast renders a long warning line — use a wide surface so all
    // tiles build and snackbars never overflow under test font metrics.
    await tester.binding.setSurfaceSize(const Size(2000, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpApp(
      const BackupSettingsPage(),
      settingsCubit: mockSettingsCubit,
    );
  }

  group('BackupSettingsPage recovery kit section', () {
    testWidgets('renders section with export and import actions', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text(l10n.recoveryKitSectionTitle), findsOneWidget);
      expect(find.byKey(const Key('recovery_kit_export_tile')), findsOneWidget);
      expect(find.byKey(const Key('recovery_kit_import_tile')), findsOneWidget);
      expect(find.text(l10n.recoveryKitExportAction), findsOneWidget);
      expect(find.text(l10n.recoveryKitImportAction), findsOneWidget);
    });

    testWidgets('export tile opens secret dialog with helper text', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('recovery_kit_export_tile')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('recovery_kit_secret_field')),
        findsOneWidget,
      );
      expect(find.text(l10n.recoveryKitExportSecretTitle), findsOneWidget);
      expect(find.text(l10n.recoveryKitSecretHelper), findsOneWidget);
    });

    testWidgets('short secret is rejected client-side, dialog stays open', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('recovery_kit_export_tile')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('recovery_kit_secret_field')),
        'short',
      );
      await tester.tap(find.byKey(const Key('recovery_kit_secret_confirm')));
      await tester.pumpAndSettle();

      verifyNever(
        () => mockRecoveryKitService.exportKit(secret: any(named: 'secret')),
      );
      // Dialog still open with the localized validation error.
      expect(
        find.byKey(const Key('recovery_kit_secret_field')),
        findsOneWidget,
      );
      expect(find.text(l10n.recoveryKitSecretTooShort), findsOneWidget);
    });

    testWidgets('service error code surfaces localized error snackbar', (
      tester,
    ) async {
      when(
        () => mockRecoveryKitService.exportKit(
          secret: any(named: 'secret'),
          outputPath: any(named: 'outputPath'),
        ),
      ).thenThrow(StateError('WRONG_SECRET'));

      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('recovery_kit_export_tile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('recovery_kit_secret_field')),
        'longenough',
      );
      await tester.tap(find.byKey(const Key('recovery_kit_secret_confirm')));
      await tester.pumpAndSettle();

      // Export warning confirm appears after the secret dialog.
      expect(find.text(l10n.recoveryKitExportConfirmTitle), findsOneWidget);
      final confirmButton = find.widgetWithText(FilledButton, l10n.confirm);
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      verify(
        () => mockRecoveryKitService.exportKit(
          secret: 'longenough',
          outputPath: any(named: 'outputPath'),
        ),
      ).called(1);
      expect(find.text(l10n.recoveryKitErrorWrongSecret), findsOneWidget);
    });

    testWidgets('KEY_ALREADY_EXISTS asks to replace then retries', (
      tester,
    ) async {
      final originalPickerPlatform = FilePickerPlatform.instance;
      addTearDown(() {
        FilePickerPlatform.instance = originalPickerPlatform;
      });
      final picker = _FakeFilePickerPlatform()
        ..result = FilePickerResult([
          PlatformFile(name: 'kit.promkey', path: '/tmp/kit.promkey', size: 64),
        ]);
      FilePickerPlatform.instance = picker;

      var callCount = 0;
      when(
        () => mockRecoveryKitService.importKit(
          filePath: any(named: 'filePath'),
          secret: any(named: 'secret'),
          replaceExisting: any(named: 'replaceExisting'),
        ),
      ).thenAnswer((inv) async {
        callCount++;
        if (callCount == 1) throw StateError('KEY_ALREADY_EXISTS');
        return 'f' * 64;
      });

      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('recovery_kit_import_tile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('recovery_kit_secret_field')),
        'longenough',
      );
      await tester.tap(find.byKey(const Key('recovery_kit_secret_confirm')));
      await tester.pumpAndSettle();

      // First attempt fails -> replace confirmation dialog.
      expect(find.text(l10n.recoveryKitImportReplaceTitle), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, l10n.confirm));
      await tester.pumpAndSettle();

      verify(
        () => mockRecoveryKitService.importKit(
          filePath: '/tmp/kit.promkey',
          secret: 'longenough',
          replaceExisting: true,
        ),
      ).called(1);
      // Warning tone success message about old-key backups.
      expect(find.text(l10n.recoveryKitImportSuccess), findsOneWidget);
    });
  });
}
