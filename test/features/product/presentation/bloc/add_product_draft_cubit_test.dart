import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

class MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

void main() {
  late MockSettingsLocalDatasource mockDs;

  setUp(() {
    mockDs = MockSettingsLocalDatasource();
    when(() => mockDs.getString(any())).thenAnswer((_) async => null);
  });

  group('AddProductDraftCubit', () {
    blocTest<AddProductDraftCubit, AddProductDraftState>(
      'initial state has no draft when storage is empty',
      build: () => AddProductDraftCubit(mockDs),
      wait: const Duration(milliseconds: 50),
      expect: () => [],
      verify: (cubit) {
        expect(cubit.state.hasDraft, isFalse);
        expect(cubit.loadDraft(), isNull);
      },
    );

    blocTest<AddProductDraftCubit, AddProductDraftState>(
      'loads draft from storage on init',
      build: () {
        when(
          () => mockDs.getString(any()),
        ).thenAnswer((_) async => jsonEncode({'name': 'Test', 'price': 10}));
        return AddProductDraftCubit(mockDs);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const AddProductDraftState(
          hasDraft: true,
          draft: {'name': 'Test', 'price': 10},
        ),
      ],
    );

    blocTest<AddProductDraftCubit, AddProductDraftState>(
      'clears invalid JSON from storage on init',
      build: () {
        when(() => mockDs.getString(any())).thenAnswer((_) async => 'not-json');
        when(() => mockDs.setString(any(), any())).thenAnswer((_) async {});
        return AddProductDraftCubit(mockDs);
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [],
      verify: (_) {
        verify(() => mockDs.setString(any(), '')).called(1);
      },
    );

    blocTest<AddProductDraftCubit, AddProductDraftState>(
      'saveDraft emits state and persists',
      build: () {
        when(() => mockDs.setString(any(), any())).thenAnswer((_) async {});
        return AddProductDraftCubit(mockDs);
      },
      wait: const Duration(milliseconds: 50),
      act: (cubit) => cubit.saveDraft({'name': 'Coffee', 'price': 50}),
      expect: () => [
        const AddProductDraftState(
          hasDraft: true,
          draft: {'name': 'Coffee', 'price': 50},
        ),
      ],
      verify: (cubit) {
        expect(cubit.loadDraft(), {'name': 'Coffee', 'price': 50});
      },
    );

    blocTest<AddProductDraftCubit, AddProductDraftState>(
      'clearDraft resets state and persists empty',
      build: () {
        when(() => mockDs.setString(any(), any())).thenAnswer((_) async {});
        return AddProductDraftCubit(mockDs);
      },
      wait: const Duration(milliseconds: 50),
      seed: () =>
          const AddProductDraftState(hasDraft: true, draft: {'name': 'Test'}),
      act: (cubit) => cubit.clearDraft(),
      expect: () => [const AddProductDraftState()],
      verify: (cubit) {
        expect(cubit.loadDraft(), isNull);
      },
    );
  });
}
