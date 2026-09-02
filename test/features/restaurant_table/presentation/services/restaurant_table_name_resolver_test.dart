import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/repositories/restaurant_table_repository.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/services/restaurant_table_name_resolver.dart';

class _MockRepository extends Mock implements RestaurantTableRepository {}

RestaurantTable _table(String id, String name) => RestaurantTable(
  id: id,
  name: name,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  late _MockRepository repo;
  late RestaurantTableNameResolver resolver;

  setUp(() {
    repo = _MockRepository();
    resolver = RestaurantTableNameResolver(repo);
    when(
      () => repo.getTableById('t1'),
    ).thenAnswer((_) async => _table('t1', 'A-01'));
    when(() => repo.getTableById('gone')).thenAnswer((_) async => null);
  });

  group('RestaurantTableNameResolver', () {
    test('resolves table name via repository', () async {
      expect(await resolver.resolve('t1'), 'A-01');
      verify(() => repo.getTableById('t1')).called(1);
    });

    test('memoizes hits — repository queried once per id', () async {
      await resolver.resolve('t1');
      await resolver.resolve('t1');
      await resolver.resolve('t1');

      verify(() => repo.getTableById('t1')).called(1);
    });

    test('unknown/deleted tables resolve to null (miss memoized)', () async {
      expect(await resolver.resolve('gone'), isNull);
      expect(await resolver.resolve('gone'), isNull);

      verify(() => repo.getTableById('gone')).called(1);
    });

    test('blank ids resolve to null without hitting the repository', () async {
      expect(await resolver.resolve('   '), isNull);

      verifyNever(() => repo.getTableById(any()));
    });

    test('ids are trimmed before lookup and caching', () async {
      expect(await resolver.resolve('  t1  '), 'A-01');

      verify(() => repo.getTableById('t1')).called(1);
    });

    test('invalidate drops the cache so ids re-resolve', () async {
      await resolver.resolve('t1');
      resolver.invalidate();
      await resolver.resolve('t1');

      verify(() => repo.getTableById('t1')).called(2);
    });
  });
}
