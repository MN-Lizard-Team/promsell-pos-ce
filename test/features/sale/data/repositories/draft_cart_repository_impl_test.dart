import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/draft_cart_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

class MockDraftCartLocalDatasource extends Mock
    implements DraftCartLocalDatasource {}

void main() {
  late MockDraftCartLocalDatasource mockDs;
  late DraftCartRepositoryImpl repo;

  setUp(() {
    mockDs = MockDraftCartLocalDatasource();
    repo = DraftCartRepositoryImpl(mockDs);
  });

  setUpAll(() {
    registerFallbackValue(const CartState());
  });

  test('createDraft delegates to datasource', () async {
    when(
      () => mockDs.createDraft(name: any(named: 'name')),
    ).thenAnswer((_) async => 'draft-001');

    final result = await repo.createDraft(name: 'Test');

    expect(result, 'draft-001');
    verify(() => mockDs.createDraft(name: 'Test')).called(1);
  });

  test('saveDraft delegates to datasource', () async {
    when(
      () => mockDs.upsertDraft(any(), any(), name: any(named: 'name')),
    ).thenAnswer((_) async {});

    await repo.saveDraft('draft-001', const CartState());

    verify(
      () => mockDs.upsertDraft('draft-001', const CartState(), name: null),
    ).called(1);
  });

  test('loadDraft delegates to datasource', () async {
    when(() => mockDs.loadDraft('draft-001')).thenAnswer((_) async => null);

    final result = await repo.loadDraft('draft-001');

    expect(result, isNull);
    verify(() => mockDs.loadDraft('draft-001')).called(1);
  });

  test('listDrafts delegates to datasource', () async {
    when(
      () => mockDs.listDrafts(includeArchived: any(named: 'includeArchived')),
    ).thenAnswer((_) async => []);

    final result = await repo.listDrafts();

    expect(result, isEmpty);
    verify(() => mockDs.listDrafts(includeArchived: false)).called(1);
  });

  test('deleteDraft delegates to datasource', () async {
    when(() => mockDs.deleteDraft(any())).thenAnswer((_) async {});

    await repo.deleteDraft('draft-001');

    verify(() => mockDs.deleteDraft('draft-001')).called(1);
  });

  test('renameDraft delegates to datasource', () async {
    when(() => mockDs.renameDraft(any(), any())).thenAnswer((_) async {});

    await repo.renameDraft('draft-001', 'NewName');

    verify(() => mockDs.renameDraft('draft-001', 'NewName')).called(1);
  });

  test('countDrafts delegates to datasource', () async {
    when(() => mockDs.countDrafts()).thenAnswer((_) async => 5);

    final result = await repo.countDrafts();

    expect(result, 5);
    verify(() => mockDs.countDrafts()).called(1);
  });

  test('archiveOldDrafts delegates to datasource', () async {
    final cutoff = DateTime(2025, 1, 1);
    when(() => mockDs.archiveOldDrafts(any())).thenAnswer((_) async => 3);

    final result = await repo.archiveOldDrafts(cutoff);

    expect(result, 3);
    verify(() => mockDs.archiveOldDrafts(cutoff)).called(1);
  });
}
