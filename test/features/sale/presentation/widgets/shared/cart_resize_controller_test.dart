import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/cart_resize_controller.dart';

void main() {
  group('CartResizeController', () {
    late CartResizeController controller;

    setUp(() {
      controller = CartResizeController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial values are correct', () {
      expect(controller.cartHeight.value, 360);
      expect(controller.cartWidth.value, 390);
      expect(controller.isDragging.value, isFalse);
    });

    test('onDragStart sets isDragging true', () {
      controller.onDragStart();
      expect(controller.isDragging.value, isTrue);
    });

    test('onDragEnd sets isDragging false', () {
      controller.onDragStart();
      controller.onDragEnd();
      expect(controller.isDragging.value, isFalse);
    });

    test('onWidthPresetChanged sets to 320 for 0', () {
      controller.onWidthPresetChanged(0.0);
      expect(controller.cartWidth.value, 320);
    });

    test('onWidthPresetChanged sets to 500 for 1', () {
      controller.onWidthPresetChanged(1.0);
      expect(controller.cartWidth.value, 500);
    });

    test('currentWidthPreset returns 0.0 at 320', () {
      controller.cartWidth.value = 320;
      expect(controller.currentWidthPreset(), 0.0);
    });

    test('currentWidthPreset returns 1.0 at 500', () {
      controller.cartWidth.value = 500;
      expect(controller.currentWidthPreset(), 1.0);
    });

    test('currentWidthPreset returns null between presets', () {
      controller.cartWidth.value = 400;
      expect(controller.currentWidthPreset(), isNull);
    });

    testWidgets('onHorizontalDrag clamps width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              controller.onHorizontalDrag(
                context,
                DragUpdateDetails(
                  globalPosition: Offset.zero,
                  delta: const Offset(100, 0),
                ),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.cartWidth.value, lessThan(390));
    });

    testWidgets('onHorizontalDragEnd snaps to 320', (tester) async {
      controller.cartWidth.value = 325;
      controller.onHorizontalDragEnd(DragEndDetails());
      expect(controller.cartWidth.value, 320);
    });

    testWidgets('onHorizontalDragEnd snaps to 500', (tester) async {
      controller.cartWidth.value = 505;
      controller.onHorizontalDragEnd(DragEndDetails());
      expect(controller.cartWidth.value, 500);
    });

    testWidgets('onHorizontalDragEnd does not snap when far', (tester) async {
      controller.cartWidth.value = 400;
      controller.onHorizontalDragEnd(DragEndDetails());
      expect(controller.cartWidth.value, 400);
    });

    testWidgets('minCartHeight returns portrait value', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final minH = controller.minCartHeight(context);
              expect(minH, 360);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
