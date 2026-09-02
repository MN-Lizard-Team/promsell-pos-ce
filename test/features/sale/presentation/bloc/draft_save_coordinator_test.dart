import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_save_coordinator.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockDraftCartRepository mockDraftRepo;
  late DraftSaveCoordinator coordinator;

  const snapshot = CartSnapshot(items: []);

  setUpAll(() {
    registerFallbackValue(snapshot);
  });

  setUp(() {
    mockDraftRepo = MockDraftCartRepository();
    coordinator = DraftSaveCoordinator(mockDraftRepo);
  });

  group('DraftSaveCoordinator — TableAlreadyBound surfacing', () {
    test('flushPending surfaces the business-rule rejection', () async {
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenThrow(const BusinessRuleError('TableAlreadyBound'));

      final surfaced = <Object>[];
      coordinator.setPending('draft-1', snapshot);
      await coordinator.flushPending(onSaveFailure: surfaced.add);

      expect(surfaced, hasLength(1));
      expect(
        surfaced.single,
        isA<BusinessRuleError>().having(
          (e) => e.rule,
          'rule',
          'TableAlreadyBound',
        ),
      );
    });

    test('flushPending does not surface unrelated failures', () async {
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenThrow(const BusinessRuleError('SomethingElse'));

      final surfaced = <Object>[];
      coordinator.setPending('draft-1', snapshot);
      await coordinator.flushPending(onSaveFailure: surfaced.add);

      expect(surfaced, isEmpty);
    });

    test('flushPending does not surface on success', () async {
      when(
        () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
      ).thenAnswer((_) async {});

      final surfaced = <Object>[];
      coordinator.setPending('draft-1', snapshot);
      await coordinator.flushPending(onSaveFailure: surfaced.add);

      expect(surfaced, isEmpty);
    });

    test(
      'debounced autosave timer surfaces the rejection when it fires',
      () async {
        when(
          () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
        ).thenThrow(const BusinessRuleError('TableAlreadyBound'));

        final surfaced = <Object>[];
        var timerFired = false;
        coordinator.scheduleAutoSave(
          draftId: 'draft-1',
          snapshot: snapshot,
          isClosed: () => false,
          onTimerFire: () async => timerFired = true,
          onSaveFailure: surfaced.add,
        );

        // Debounce default is 1500ms.
        await Future<void>.delayed(const Duration(milliseconds: 1600));

        expect(surfaced, hasLength(1));
        expect(timerFired, isTrue);
      },
    );
  });
}
