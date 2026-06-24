import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({
    super.key,
    required this.axis,
    required this.isDragging,
    required this.semanticLabel,
    required this.onDragStart,
    required this.onDragEnd,
    this.onVerticalDragUpdate,
    this.onHorizontalDragUpdate,
    this.onVerticalDragEnd,
    this.onHorizontalDragEnd,
  });

  final Axis axis;
  final ValueListenable<bool> isDragging;
  final String semanticLabel;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<DragUpdateDetails>? onVerticalDragUpdate;
  final ValueChanged<DragUpdateDetails>? onHorizontalDragUpdate;
  final ValueChanged<DragEndDetails>? onVerticalDragEnd;
  final ValueChanged<DragEndDetails>? onHorizontalDragEnd;

  @override
  Widget build(BuildContext context) {
    final isVertical = axis == Axis.vertical;
    return MouseRegion(
      cursor: isVertical
          ? SystemMouseCursors.resizeRow
          : SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onVerticalDragStart: isVertical ? (_) => onDragStart() : null,
        onVerticalDragUpdate: isVertical ? onVerticalDragUpdate : null,
        onVerticalDragEnd: isVertical ? onVerticalDragEnd : null,
        onVerticalDragCancel: onDragEnd,
        onHorizontalDragStart: !isVertical ? (_) => onDragStart() : null,
        onHorizontalDragUpdate: !isVertical ? onHorizontalDragUpdate : null,
        onHorizontalDragEnd: !isVertical ? onHorizontalDragEnd : null,
        onHorizontalDragCancel: onDragEnd,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          label: semanticLabel,
          child: SizedBox(
            width: isVertical ? null : 20,
            height: isVertical ? 24 : null,
            child: Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: isDragging,
                builder: (context, dragging, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: isVertical ? (dragging ? 56 : 40) : 6,
                    height: isVertical ? 6 : (dragging ? 56 : 40),
                    decoration: BoxDecoration(
                      color: dragging
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
