import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDraftCartRepository mockDraftRepo;
  late MockSettingsRepository mockSettingsRepo;

  setUp(() {
    mockDraftRepo = MockDraftCartRepository();
    mockSettingsRepo = MockSettingsRepository();
    registerFallbackValue(const CartState());
  });

  DraftBloc buildBloc() =>
      DraftBloc(draftRepo: mockDraftRepo, settingsRepo: mockSettingsRepo);

  group('DraftBloc — Bug 2: _flushPendingSave saves pending cart', () {
    test(
      'flushPendingSave saves pending cart state before switching draft',
      () async {
        when(
          () => mockDraftRepo.archiveOldDrafts(any()),
        ).thenAnswer((_) async => 0);
        when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
        when(
          () => mockDraftRepo.createDraft(name: any(named: 'name')),
        ).thenAnswer((_) async => 'draft-1');
        when(
          () => mockDraftRepo.createDraft(),
        ).thenAnswer((_) async => 'draft-1');
        when(
          () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
        ).thenAnswer((_) async {});
        when(() => mockDraftRepo.loadDraft(any())).thenAnswer(
          (_) async => DraftCart(
            id: 'draft-2',
            name: 'Draft 2',
            items: const [],
            updatedAt: DateTime(2025, 1, 1),
          ),
        );
        when(() => mockDraftRepo.deleteDraft(any())).thenAnswer((_) async {});

        final bloc = buildBloc();
        bloc.add(const DraftInitialized());
        await bloc.stream.first;

        const testCartState = CartState(items: [], note: 'test note');
        bloc.add(const DraftAutoSaveRequested(testCartState));

        bloc.add(const DraftSwitched('draft-2'));
        await bloc.stream.first;

        final captured = verify(() {
          mockDraftRepo.saveDraft(
            'draft-1',
            captureAny(),
            name: any(named: 'name'),
          );
        }).captured;

        expect(captured, isNotEmpty);
        expect(captured.last, isA<CartState>());
        expect((captured.last as CartState).note, 'test note');

        await bloc.close();
      },
    );
  });

  group('DraftInitialized', () {
    test('creates new draft when no drafts exist', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());

      final state = await bloc.stream.first;
      expect(state.activeDraftId, 'draft-1');
      await bloc.close();
    });

    test('loads first existing draft', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer(
        (_) async => [
          DraftCart(
            id: 'draft-1',
            name: 'Saved Draft',
            items: const [],
            updatedAt: DateTime(2025, 1, 1),
          ),
        ],
      );

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());

      final state = await bloc.stream.first;
      expect(state.activeDraftId, 'draft-1');
      expect(state.activeDraftName, 'Saved Draft');
      await bloc.close();
    });
  });

  group('DraftCreated', () {
    test('creates draft when under max limit', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-2');
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      bloc.add(const DraftCreated(name: 'New Draft'));
      final state = await bloc.stream.first;

      expect(state.activeDraftId, 'draft-2');
      expect(state.activeDraftName, 'New Draft');
      await bloc.close();
    });

    test('emits error when max drafts reached', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 30);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      bloc.add(const DraftCreated(name: 'New Draft'));
      final state = await bloc.stream.first;

      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('Max drafts'));
      await bloc.close();
    });
  });

  group('DraftSwitched', () {
    test('switches to loaded draft successfully', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.loadDraft('draft-2')).thenAnswer(
        (_) async => DraftCart(
          id: 'draft-2',
          name: 'Draft 2',
          items: const [],
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      bloc.add(const DraftSwitched('draft-2'));
      final state = await bloc.stream.first;

      expect(state.activeDraftId, 'draft-2');
      expect(state.activeDraftName, 'Draft 2');
      await bloc.close();
    });

    test('does nothing when switching to same draft', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      bloc.add(const DraftSwitched('draft-1'));
      await bloc.close();

      // Should not emit any new state (same draft)
      expect(bloc.state.activeDraftId, 'draft-1');
    });
  });

  group('DraftRotated', () {
    test('creates new draft and deletes old one', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');
      when(() => mockDraftRepo.deleteDraft(any())).thenAnswer((_) async {});
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      // Override createDraft for the rotated call
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-2');

      bloc.add(const DraftRotated());
      final state = await bloc.stream.first;

      expect(state.activeDraftId, 'draft-2');
      expect(state.activeDraftName, startsWith('Bill #'));
      verify(() => mockDraftRepo.deleteDraft('draft-1')).called(1);
      await bloc.close();
    });
  });

  group('DraftBloc — Bug 4: try-catch in handlers', () {
    test('_onSwitched emits error state when loadDraft throws', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      when(
        () => mockDraftRepo.loadDraft(any()),
      ).thenThrow(Exception('DB error'));
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});

      bloc.add(const DraftSwitched('draft-2'));

      final state = await bloc.stream.first;
      expect(state.errorMessage, isNotNull);

      await bloc.close();
    });

    test('_onCreated emits error state when createDraft throws', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenThrow(Exception('DB error'));
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});

      bloc.add(const DraftCreated(name: 'New Draft'));

      final state = await bloc.stream.first;
      expect(state.errorMessage, isNotNull);

      await bloc.close();
    });

    test('_onDeleted emits error state when deleteDraft throws', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      when(
        () => mockDraftRepo.deleteDraft(any()),
      ).thenThrow(Exception('DB error'));

      bloc.add(const DraftDeleted('draft-1'));

      final state = await bloc.stream.first;
      expect(state.errorMessage, isNotNull);

      await bloc.close();
    });

    test('_onRenamed emits error state when renameDraft throws', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      when(
        () => mockDraftRepo.renameDraft(any(), any()),
      ).thenThrow(Exception('DB error'));

      bloc.add(const DraftRenamed(draftId: 'draft-1', name: 'Renamed'));

      final state = await bloc.stream.first;
      expect(state.errorMessage, isNotNull);

      await bloc.close();
    });
  });
}
