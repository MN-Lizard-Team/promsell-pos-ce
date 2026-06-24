import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

class MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

Matcher stateMatcher(List<String> searches) =>
    isA<SearchHistoryState>().having((s) => s.searches, 'searches', searches);

void main() {
  late MockSettingsLocalDatasource mockDs;
  const key = 'search_history';

  setUp(() {
    mockDs = MockSettingsLocalDatasource();
  });

  group('SearchHistoryCubit', () {
    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'load emits empty when no stored data',
      build: () {
        when(() => mockDs.getString(key)).thenAnswer((_) async => null);
        return SearchHistoryCubit(mockDs, key);
      },
      act: (cubit) => cubit.load(),
      expect: () => [stateMatcher([])],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'load emits empty when stored data is empty string',
      build: () {
        when(() => mockDs.getString(key)).thenAnswer((_) async => '');
        return SearchHistoryCubit(mockDs, key);
      },
      act: (cubit) => cubit.load(),
      expect: () => [stateMatcher([])],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'load emits searches from stored JSON',
      build: () {
        when(
          () => mockDs.getString(key),
        ).thenAnswer((_) async => jsonEncode(['apple', 'banana']));
        return SearchHistoryCubit(mockDs, key);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        stateMatcher(['apple', 'banana']),
      ],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'load emits empty on invalid JSON',
      build: () {
        when(() => mockDs.getString(key)).thenAnswer((_) async => 'not-json');
        return SearchHistoryCubit(mockDs, key);
      },
      act: (cubit) => cubit.load(),
      expect: () => [stateMatcher([])],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'add prepends query and persists',
      build: () {
        when(() => mockDs.setString(key, any())).thenAnswer((_) async {});
        return SearchHistoryCubit(mockDs, key);
      },
      act: (cubit) => cubit.add('coffee'),
      expect: () => [
        stateMatcher(['coffee']),
      ],
      verify: (cubit) {
        verify(() => mockDs.setString(key, jsonEncode(['coffee']))).called(1);
      },
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'add does nothing for empty query',
      build: () {
        when(() => mockDs.setString(key, any())).thenAnswer((_) async {});
        return SearchHistoryCubit(mockDs, key);
      },
      act: (cubit) => cubit.add('  '),
      expect: () => [],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'add moves existing query to front',
      build: () {
        when(() => mockDs.setString(key, any())).thenAnswer((_) async {});
        return SearchHistoryCubit(mockDs, key);
      },
      seed: () => const SearchHistoryState(searches: ['a', 'b', 'c']),
      act: (cubit) => cubit.add('b'),
      expect: () => [
        stateMatcher(['b', 'a', 'c']),
      ],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'add limits to 10 entries',
      build: () {
        when(() => mockDs.setString(key, any())).thenAnswer((_) async {});
        return SearchHistoryCubit(mockDs, key);
      },
      seed: () => const SearchHistoryState(
        searches: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
      ),
      act: (cubit) => cubit.add('new'),
      expect: () => [
        stateMatcher(['new', '1', '2', '3', '4', '5', '6', '7', '8', '9']),
      ],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'remove removes query from list',
      build: () {
        when(() => mockDs.setString(key, any())).thenAnswer((_) async {});
        return SearchHistoryCubit(mockDs, key);
      },
      seed: () => const SearchHistoryState(searches: ['a', 'b', 'c']),
      act: (cubit) => cubit.remove('b'),
      expect: () => [
        stateMatcher(['a', 'c']),
      ],
    );

    blocTest<SearchHistoryCubit, SearchHistoryState>(
      'clear empties the list',
      build: () {
        when(() => mockDs.setString(key, any())).thenAnswer((_) async {});
        return SearchHistoryCubit(mockDs, key);
      },
      seed: () => const SearchHistoryState(searches: ['a', 'b']),
      act: (cubit) => cubit.clear(),
      expect: () => [stateMatcher([])],
    );
  });
}
