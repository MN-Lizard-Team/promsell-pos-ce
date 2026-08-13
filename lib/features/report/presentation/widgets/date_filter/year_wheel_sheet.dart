import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Year picker bottom sheet with shake + red flash on future year.
class YearWheelSheet extends StatefulWidget {
  const YearWheelSheet({
    super.key,
    required this.minYear,
    required this.maxYear,
    required this.initialYear,
    required this.maxSelectableIndex,
  });

  final int minYear;
  final int maxYear;
  final int initialYear;
  final int maxSelectableIndex;

  @override
  State<YearWheelSheet> createState() => _YearWheelSheetState();
}

class _YearWheelSheetState extends State<YearWheelSheet>
    with SingleTickerProviderStateMixin {
  late final FixedExtentScrollController _wheelController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  int _selectedIndex = 0;
  int _flashRedIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialYear - widget.minYear;
    _wheelController = FixedExtentScrollController(initialItem: _selectedIndex);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int i) {
    if (i > widget.maxSelectableIndex) {
      HapticFeedback.heavyImpact();
      // Flash red on the future item.
      setState(() => _flashRedIndex = i);
      // Shake animation.
      _shakeController.forward(from: 0);
      // Delay snap-back so the red flash is visible on the future year.
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _wheelController.animateToItem(
          widget.maxSelectableIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
      // Clear red flash after 700ms.
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _flashRedIndex = -1);
      });
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Text(
                  l10n.dateFilterPickYear,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(TablerIcons.x, size: 24),
                  splashRadius: 24,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outline.withValues(alpha: 0.12)),
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final shake = _shakeAnimation.value;
              final offset = shake > 0
                  ? Offset(sin(shake * pi * 6) * 6 * (1 - shake), 0)
                  : Offset.zero;
              return Transform.translate(offset: offset, child: child);
            },
            child: SizedBox(
              height: 280,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 44,
                perspective: 0.003,
                diameterRatio: 1.2,
                controller: _wheelController,
                onSelectedItemChanged: _onSelectedItemChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.maxYear - widget.minYear + 1,
                  builder: (context, i) {
                    final y = widget.minYear + i;
                    final isSelected = i == _selectedIndex;
                    final isFuture = i > widget.maxSelectableIndex;
                    final isFlashingRed = i == _flashRedIndex;
                    return Center(
                      child: Opacity(
                        opacity: isFuture ? 0.3 : 1.0,
                        child: Text(
                          '$y',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isFlashingRed
                                ? scheme.error
                                : (isFuture
                                      ? scheme.onSurface.withValues(alpha: 0.3)
                                      : (isSelected
                                            ? scheme.primary
                                            : scheme.onSurface.withValues(
                                                alpha: 0.5,
                                              ))),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                onPressed: _selectedIndex > widget.maxSelectableIndex
                    ? null
                    : () => Navigator.of(
                        context,
                      ).pop(widget.minYear + _selectedIndex),
                child: Text(l10n.dateFilterSelectYear),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
