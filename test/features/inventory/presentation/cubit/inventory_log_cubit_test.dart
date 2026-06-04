import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_cubit.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/cubit/inventory_log_state.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  group('InventoryLogCubit', () {
    late MockWatchInventoryLogs mockWatch;
    late InventoryLogCubit cubit;

    setUp(() {
      mockWatch = MockWatchInventoryLogs();
      cubit = InventoryLogCubit(watchInventoryLogs: mockWatch);
    });

    tearDown(() => cubit.close());

    blocTest<InventoryLogCubit, InventoryLogState>(
      'initial state is initial',
      build: () => cubit,
      verify: (c) => expect(c.state.status, InventoryLogStatus.initial),
    );

    blocTest<InventoryLogCubit, InventoryLogState>(
      'load emits loading then success',
      build: () => cubit,
      setUp: () {
        when(
          () => mockWatch(),
        ).thenAnswer((_) => Stream.value([tInventoryLog, tInventoryLog2]));
      },
      act: (c) => c.load(),
      expect: () => [
        const InventoryLogState(status: InventoryLogStatus.loading),
        InventoryLogState(
          status: InventoryLogStatus.success,
          logs: [tInventoryLog, tInventoryLog2],
        ),
      ],
    );

    blocTest<InventoryLogCubit, InventoryLogState>(
      'load with productId passes it through',
      build: () => cubit,
      setUp: () {
        when(
          () => mockWatch(productId: 'p1'),
        ).thenAnswer((_) => Stream.value([tInventoryLog]));
      },
      act: (c) => c.load(productId: 'p1'),
      expect: () => [
        const InventoryLogState(status: InventoryLogStatus.loading),
        InventoryLogState(
          status: InventoryLogStatus.success,
          logs: [tInventoryLog],
        ),
      ],
      verify: (_) => verify(() => mockWatch(productId: 'p1')).called(1),
    );

    blocTest<InventoryLogCubit, InventoryLogState>(
      'load emits failure on stream error',
      build: () => cubit,
      setUp: () {
        when(
          () => mockWatch(),
        ).thenAnswer((_) => Stream.error(Exception('db error')));
      },
      act: (c) => c.load(),
      expect: () => [
        const InventoryLogState(status: InventoryLogStatus.loading),
        const InventoryLogState(
          status: InventoryLogStatus.failure,
          errorMessage: 'Exception: db error',
        ),
      ],
    );
  });
}
