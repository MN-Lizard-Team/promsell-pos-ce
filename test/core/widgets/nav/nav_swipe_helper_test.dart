import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/nav/nav_swipe_helper.dart';

void main() {
  group('NavSwipeHelper', () {
    int? result;

    setUp(() => result = null);

    test('swipe right at index > 0 calls onTap with previous index', () {
      NavSwipeHelper.handleSwipe(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(500, 0)),
          primaryVelocity: 500,
        ),
        2,
        5,
        (i) => result = i,
      );

      expect(result, 1);
    });

    test('swipe left at index < last calls onTap with next index', () {
      NavSwipeHelper.handleSwipe(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(-500, 0)),
          primaryVelocity: -500,
        ),
        1,
        5,
        (i) => result = i,
      );

      expect(result, 2);
    });

    test('swipe right at index 0 does not call onTap', () {
      NavSwipeHelper.handleSwipe(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(500, 0)),
          primaryVelocity: 500,
        ),
        0,
        5,
        (i) => result = i,
      );

      expect(result, isNull);
    });

    test('swipe left at last index does not call onTap', () {
      NavSwipeHelper.handleSwipe(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(-500, 0)),
          primaryVelocity: -500,
        ),
        4,
        5,
        (i) => result = i,
      );

      expect(result, isNull);
    });

    test('slow swipe below threshold does not call onTap', () {
      NavSwipeHelper.handleSwipe(
        DragEndDetails(
          velocity: const Velocity(pixelsPerSecond: Offset(100, 0)),
          primaryVelocity: 100,
        ),
        1,
        5,
        (i) => result = i,
      );

      expect(result, isNull);
    });

    test(
      'swipe exactly at threshold fires (abs < threshold is false at 300)',
      () {
        NavSwipeHelper.handleSwipe(
          DragEndDetails(
            velocity: const Velocity(
              pixelsPerSecond: Offset(NavSwipeHelper.threshold, 0),
            ),
            primaryVelocity: NavSwipeHelper.threshold,
          ),
          1,
          5,
          (i) => result = i,
        );

        expect(result, 0);
      },
    );
  });
}
