import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_bill_switch_guard.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDraftCartRepository mockDraftRepo;
  late MockSettingsRepository mockSettingsRepo;

  setUp(() {
    mockDraftRepo = MockDraftCartRepository();
    mockSettingsRepo = MockSettingsRepository();
    registerFallbackValue(const CartSnapshot(items: []));
    // Init / empty / rotate always call createDraft(name: …) via DraftNaming.
    // Tests may override; bare createDraft() alone no longer matches.
    when(
      () => mockDraftRepo.createDraft(name: any(named: 'name')),
    ).thenAnswer((_) async => 'draft-1');
    when(() => mockDraftRepo.createDraft()).thenAnswer((_) async => 'draft-1');
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
        expect(captured.last, isA<CartSnapshot>());
        expect((captured.last as CartSnapshot).note, 'test note');

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
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-1');
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());

      final state = await bloc.stream.first;
      expect(state.activeDraftId, 'draft-1');
      expect(state.activeDraftName, matches(RegExp(r'^B-\d{4}$')));
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
      expect(state.errorMessage, startsWith('maxDraftsReached:'));
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
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-1');
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

      // Override createDraft for the rotated call (named via DraftNaming).
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-2');
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-2');

      bloc.add(const DraftRotated());
      final state = await bloc.stream.first;

      expect(state.activeDraftId, 'draft-2');
      // SSOT empty-bill format: B-HHmm (4 digits), not legacy ms%100000.
      expect(state.activeDraftName, matches(RegExp(r'^B-\d{4}$')));
      verify(() => mockDraftRepo.deleteDraft('draft-1')).called(1);
      verify(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).called(greaterThan(0));
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

  group('DraftParkRequested / DraftStartNewBillRequested', () {
    test('park saves cart then creates empty draft', () async {
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
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());
      // second create for park empty
      var createN = 0;
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async {
        createN++;
        return createN == 1 ? 'draft-1' : 'draft-2';
      });
      when(() => mockDraftRepo.createDraft()).thenAnswer((_) async {
        createN++;
        return createN <= 1 ? 'draft-1' : 'draft-2';
      });

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      bloc.add(const DraftParkRequested(CartState()));
      final terminal = await bloc.stream.firstWhere(
        (s) =>
            s.opStatus == DraftOpStatus.success ||
            s.opStatus == DraftOpStatus.failure,
      );
      // may need wait more for create step
      DraftState last = terminal;
      if (last.opStatus != DraftOpStatus.success || last.lastOp != 'park') {
        last = await bloc.stream.firstWhere(
          (s) =>
              s.lastOp == 'park' &&
              (s.opStatus == DraftOpStatus.success ||
                  s.opStatus == DraftOpStatus.failure),
        );
      }
      expect(last.opStatus, DraftOpStatus.success);
      expect(last.activeDraftId, isNot(equals('draft-1')));
      verify(
        () =>
            mockDraftRepo.saveDraft('draft-1', any(), name: any(named: 'name')),
      ).called(greaterThan(0));
      await bloc.close();
    });

    test('park with name saves name on parked draft not new empty', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      var createN = 0;
      when(() => mockDraftRepo.createDraft()).thenAnswer((_) async {
        createN++;
        return createN == 1 ? 'draft-1' : 'draft-2';
      });
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async {
        createN++;
        return createN == 1 ? 'draft-1' : 'draft-2';
      });
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;
      clearInteractions(mockDraftRepo);
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-2');
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-2');
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});

      bloc.add(const DraftParkRequested(CartState(), name: 'Table 7'));
      final last = await bloc.stream.firstWhere(
        (s) =>
            s.lastOp == 'park' &&
            (s.opStatus == DraftOpStatus.success ||
                s.opStatus == DraftOpStatus.failure),
      );
      expect(last.opStatus, DraftOpStatus.success);
      expect(last.activeDraftId, 'draft-2');
      // Name applies to parked draft (draft-1), not the empty active draft.
      verify(
        () => mockDraftRepo.saveDraft('draft-1', any(), name: 'Table 7'),
      ).called(greaterThan(0));
      // New empty gets auto name (forNewEmptyBill), never null.
      verify(
        () => mockDraftRepo.createDraft(
          name: any(named: 'name', that: isNotNull),
        ),
      ).called(greaterThan(0));
      expect(last.activeDraftName, matches(RegExp(r'^B-\d{4}$')));
      await bloc.close();
    });

    test(
      'newBill fails max drafts without switching away on create fail',
      () async {
        when(
          () => mockDraftRepo.archiveOldDrafts(any()),
        ).thenAnswer((_) async => 0);
        when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
        when(
          () => mockDraftRepo.createDraft(),
        ).thenAnswer((_) async => 'draft-1');
        when(
          () => mockDraftRepo.createDraft(name: any(named: 'name')),
        ).thenAnswer((_) async => 'draft-1');
        when(
          () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
        ).thenAnswer((_) async {});
        when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 30);
        when(() => mockSettingsRepo.load()).thenAnswer(
          (_) async => const Settings().copyWith(), // max drafts default 30
        );

        final bloc = buildBloc();
        bloc.add(const DraftInitialized());
        await bloc.stream.first;
        final active = bloc.state.activeDraftId;

        // force count at cap for create step
        when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 30);

        bloc.add(const DraftStartNewBillRequested(CartState()));
        final last = await bloc.stream.firstWhere(
          (s) =>
              s.lastOp == 'newBill' &&
              (s.opStatus == DraftOpStatus.success ||
                  s.opStatus == DraftOpStatus.failure),
        );
        expect(last.opStatus, DraftOpStatus.failure);
        expect(last.errorMessage, startsWith('maxDraftsReached'));
        expect(last.activeDraftId, active);
        await bloc.close();
      },
    );

    test('park fails at max drafts without saving or creating', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-1');
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-1');
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 30);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;
      final active = bloc.state.activeDraftId;
      clearInteractions(mockDraftRepo);

      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 30);

      bloc.add(const DraftParkRequested(CartState()));
      final last = await bloc.stream.firstWhere(
        (s) =>
            s.lastOp == 'park' &&
            (s.opStatus == DraftOpStatus.success ||
                s.opStatus == DraftOpStatus.failure),
      );
      expect(last.opStatus, DraftOpStatus.failure);
      expect(last.errorMessage, startsWith('maxDraftsReached'));
      expect(last.activeDraftId, active);
      verifyNever(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      );
      verifyNever(() => mockDraftRepo.createDraft(name: any(named: 'name')));
      await bloc.close();
    });

    test(
      'park fails when save throws and does not create empty draft',
      () async {
        when(
          () => mockDraftRepo.archiveOldDrafts(any()),
        ).thenAnswer((_) async => 0);
        when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
        when(
          () => mockDraftRepo.createDraft(),
        ).thenAnswer((_) async => 'draft-1');
        when(
          () => mockDraftRepo.createDraft(name: any(named: 'name')),
        ).thenAnswer((_) async => 'draft-1');
        when(
          () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
        ).thenThrow(Exception('disk full'));
        when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
        when(
          () => mockSettingsRepo.load(),
        ).thenAnswer((_) async => const Settings());

        final bloc = buildBloc();
        bloc.add(const DraftInitialized());
        await bloc.stream.first;
        final active = bloc.state.activeDraftId;
        clearInteractions(mockDraftRepo);

        when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
        when(
          () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
        ).thenThrow(Exception('disk full'));

        bloc.add(const DraftParkRequested(CartState()));
        final last = await bloc.stream.firstWhere(
          (s) =>
              s.lastOp == 'park' &&
              (s.opStatus == DraftOpStatus.success ||
                  s.opStatus == DraftOpStatus.failure),
        );
        expect(last.opStatus, DraftOpStatus.failure);
        expect(last.activeDraftId, active);
        verifyNever(() => mockDraftRepo.createDraft(name: any(named: 'name')));
        await bloc.close();
      },
    );

    test('named newBill parks then activates draft with given name', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      var createN = 0;
      when(() => mockDraftRepo.createDraft()).thenAnswer((_) async {
        createN++;
        return createN == 1 ? 'draft-1' : 'draft-2';
      });
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((inv) async {
        createN++;
        final name = inv.namedArguments[#name] as String?;
        return name == 'Table 5' ? 'draft-named' : 'draft-$createN';
      });
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);

      bloc.add(const DraftStartNewBillRequested(CartState(), name: 'Table 5'));
      final last = await bloc.stream.firstWhere(
        (s) =>
            s.lastOp == 'newBill' &&
            (s.opStatus == DraftOpStatus.success ||
                s.opStatus == DraftOpStatus.failure),
      );
      expect(last.opStatus, DraftOpStatus.success);
      expect(last.activeDraftId, 'draft-named');
      expect(last.activeDraftName, 'Table 5');
      verify(() => mockDraftRepo.createDraft(name: 'Table 5')).called(1);
      await bloc.close();
    });

    test('1-tap park keeps existing active name', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer(
        (_) async => [
          DraftCart(
            id: 'draft-1',
            name: 'VIP',
            items: const [],
            updatedAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      when(() => mockDraftRepo.loadDraft('draft-1')).thenAnswer(
        (_) async => DraftCart(
          id: 'draft-1',
          name: 'VIP',
          items: const [],
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-2');
      when(
        () => mockDraftRepo.createDraft(),
      ).thenAnswer((_) async => 'draft-2');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;
      expect(bloc.state.activeDraftName, 'VIP');

      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      // name: null = 1-tap → preserve VIP on parked draft
      bloc.add(const DraftParkRequested(CartState(), name: null));
      final last = await bloc.stream.firstWhere(
        (s) =>
            s.lastOp == 'park' &&
            (s.opStatus == DraftOpStatus.success ||
                s.opStatus == DraftOpStatus.failure),
      );
      expect(last.opStatus, DraftOpStatus.success);
      verify(
        () => mockDraftRepo.saveDraft('draft-1', any(), name: 'VIP'),
      ).called(greaterThan(0));
      expect(last.activeDraftName, matches(RegExp(r'^B-\d{4}$')));
      await bloc.close();
    });

    test('unnamed newBill gets auto empty name', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      var createN = 0;
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async {
        createN++;
        return 'draft-$createN';
      });
      when(() => mockDraftRepo.createDraft()).thenAnswer((_) async {
        createN++;
        return 'draft-$createN';
      });
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;
      expect(bloc.state.activeDraftName, matches(RegExp(r'^B-\d{4}$')));

      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      bloc.add(const DraftStartNewBillRequested(CartState()));
      final last = await bloc.stream.firstWhere(
        (s) =>
            s.lastOp == 'newBill' &&
            (s.opStatus == DraftOpStatus.success ||
                s.opStatus == DraftOpStatus.failure),
      );
      expect(last.opStatus, DraftOpStatus.success);
      expect(last.activeDraftName, matches(RegExp(r'^B-\d{4}$')));
      await bloc.close();
    });

    test('autosave blackout skips empty cart after park', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      var createN = 0;
      when(() => mockDraftRepo.createDraft()).thenAnswer((_) async {
        createN++;
        return 'draft-$createN';
      });
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async {
        createN++;
        return 'draft-$createN';
      });
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      bloc.add(const DraftParkRequested(CartState()));
      await bloc.stream.firstWhere(
        (s) => s.lastOp == 'park' && s.opStatus == DraftOpStatus.success,
      );
      clearInteractions(mockDraftRepo);

      // Empty cart within blackout: must not schedule save of empty wipe.
      bloc.add(const DraftAutoSaveRequested(CartState()));
      await Future<void>.delayed(const Duration(milliseconds: 1600));
      verifyNever(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      );

      await bloc.close();
    });

    test('autosave allows non-empty cart during blackout after park', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      var createN = 0;
      when(() => mockDraftRepo.createDraft()).thenAnswer((_) async {
        createN++;
        return 'draft-$createN';
      });
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async {
        createN++;
        return 'draft-$createN';
      });
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const Settings());

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;
      when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 1);

      bloc.add(const DraftParkRequested(CartState()));
      final parked = await bloc.stream.firstWhere(
        (s) => s.lastOp == 'park' && s.opStatus == DraftOpStatus.success,
      );
      final activeId = parked.activeDraftId!;
      clearInteractions(mockDraftRepo);

      final now = DateTime(2025, 1, 15);
      final cartWithItem = CartState(
        items: [
          CartItem(
            product: Product(
              id: 'p-blackout',
              name: 'Item',
              price: Money.fromDouble(10),
              stock: 5,
              isActive: true,
              trackStock: true,
              createdAt: now,
              updatedAt: now,
            ),
            qty: 1,
          ),
        ],
      );
      expect(cartWithItem.isEmpty, isFalse);

      bloc.add(DraftAutoSaveRequested(cartWithItem));
      await Future<void>.delayed(const Duration(milliseconds: 1600));

      verify(
        () =>
            mockDraftRepo.saveDraft(activeId, any(), name: any(named: 'name')),
      ).called(greaterThan(0));
      await bloc.close();
    });
  });

  group('Save Bill integrity P0', () {
    test('DraftSwitched paymentLocked rejects without load', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      bloc.add(const DraftSwitched('draft-2', paymentLocked: true));
      final state = await bloc.stream.firstWhere(
        (s) => s.lastOp == 'switch' && s.opStatus == DraftOpStatus.failure,
      );
      expect(state.errorMessage, DraftBillSwitchGuard.errorCode);
      expect(state.activeDraftId, 'draft-1');
      verifyNever(() => mockDraftRepo.loadDraft(any()));
      await bloc.close();
    });

    test('DraftDeleted paymentLocked rejects without delete', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-1');

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      bloc.add(const DraftDeleted('draft-1', paymentLocked: true));
      final state = await bloc.stream.firstWhere(
        (s) => s.lastOp == 'delete' && s.opStatus == DraftOpStatus.failure,
      );
      expect(state.errorMessage, DraftBillSwitchGuard.errorCode);
      verifyNever(() => mockDraftRepo.deleteDraft(any()));
      await bloc.close();
    });

    test('DraftSwitched with liveCart force-saves before load', () async {
      when(
        () => mockDraftRepo.archiveOldDrafts(any()),
      ).thenAnswer((_) async => 0);
      when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
      when(
        () => mockDraftRepo.createDraft(name: any(named: 'name')),
      ).thenAnswer((_) async => 'draft-1');
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});
      when(() => mockDraftRepo.loadDraft('draft-2')).thenAnswer(
        (_) async => DraftCart(
          id: 'draft-2',
          name: 'B',
          items: const [],
          updatedAt: DateTime(2026),
        ),
      );

      final bloc = buildBloc();
      bloc.add(const DraftInitialized());
      await bloc.stream.first;

      final product = Product(
        id: 'p1',
        name: 'Water',
        price: Money.fromDouble(10),
        stock: 5,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final live = CartState(items: [CartItem(product: product, qty: 2)]);
      bloc.add(DraftSwitched('draft-2', liveCart: live));
      final state = await bloc.stream.firstWhere(
        (s) => s.lastOp == 'switch' && s.opStatus == DraftOpStatus.success,
      );
      expect(state.activeDraftId, 'draft-2');
      verify(
        () =>
            mockDraftRepo.saveDraft('draft-1', any(), name: any(named: 'name')),
      ).called(greaterThan(0));
      verify(() => mockDraftRepo.loadDraft('draft-2')).called(1);
      await bloc.close();
    });
  });
}
