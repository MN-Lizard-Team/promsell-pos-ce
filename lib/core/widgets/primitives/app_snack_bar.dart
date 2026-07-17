import 'dart:async';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

abstract final class AppSnackBar {
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    if (!context.mounted) return;
    _show(
      context,
      message,
      duration: duration,
      backgroundColor: AppColors.success,
      foregroundColor: AppColors.onSuccess,
      icon: Icons.check_circle,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;
    _show(
      context,
      message,
      duration: duration,
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.onError,
      icon: Icons.error,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    if (!context.mounted) return;
    _show(
      context,
      message,
      duration: duration,
      backgroundColor: AppColors.warning,
      foregroundColor: AppColors.onWarning,
      icon: Icons.warning,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    if (!context.mounted) return;
    _show(
      context,
      message,
      duration: duration,
      backgroundColor: AppColors.info,
      foregroundColor: AppColors.onInfo,
      icon: Icons.info,
    );
  }

  static void withAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (!context.mounted) return;
    final overlay = Overlay.of(context);
    final entry = _ActionEntry(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
    overlay.insert(entry.overlayEntry);
  }

  static void _show(
    BuildContext context,
    String message, {
    required Duration duration,
    required Color backgroundColor,
    required Color foregroundColor,
    IconData? icon,
  }) {
    final overlay = Overlay.of(context);
    final entry = _SimpleEntry(
      message: message,
      duration: duration,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: icon,
    );
    overlay.insert(entry.overlayEntry);
  }
}

// Simple toast (top, no action)
class _SimpleEntry {
  _SimpleEntry({
    required this.message,
    required this.duration,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
  }) {
    overlayEntry = OverlayEntry(builder: (_) => _SimpleToast(state: this));
  }

  final String message;
  final Duration duration;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;
  late final OverlayEntry overlayEntry;

  void remove() {
    if (overlayEntry.mounted) overlayEntry.remove();
  }
}

class _SimpleToast extends StatefulWidget {
  const _SimpleToast({required this.state});

  final _SimpleEntry state;

  @override
  State<_SimpleToast> createState() => _SimpleToastState();
}

class _SimpleToastState extends State<_SimpleToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Timer _dismissTimer;

  static const _fadeIn = Duration(milliseconds: 150);
  static const _fadeOut = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _fadeIn);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _dismissTimer = Timer(widget.state.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    _ctrl.duration = _fadeOut;
    await _ctrl.reverse();
    widget.state.remove();
  }

  @override
  void dispose() {
    _dismissTimer.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final state = widget.state;
    final fg = state.foregroundColor;

    return Positioned(
      top: topPadding + 16,
      left: 0,
      right: 0,
      child: Semantics(
        liveRegion: true,
        label: state.message,
        child: GestureDetector(
          onTap: _dismiss,
          child: Center(
            child: FadeTransition(
              opacity: _opacity,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: state.backgroundColor,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.icon != null) ...[
                        Icon(state.icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        state.message,
                        style: textTheme.labelLarge?.copyWith(color: fg),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Action toast (bottom, with undo button)
class _ActionEntry {
  _ActionEntry({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
  }) {
    overlayEntry = OverlayEntry(builder: (_) => _ActionToast(state: this));
  }

  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Duration duration;
  late final OverlayEntry overlayEntry;

  void remove() {
    if (overlayEntry.mounted) overlayEntry.remove();
  }
}

class _ActionToast extends StatefulWidget {
  const _ActionToast({required this.state});

  final _ActionEntry state;

  @override
  State<_ActionToast> createState() => _ActionToastState();
}

class _ActionToastState extends State<_ActionToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Timer _dismissTimer;

  static const _fadeIn = Duration(milliseconds: 150);
  static const _fadeOut = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _fadeIn);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _dismissTimer = Timer(widget.state.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    _ctrl.duration = _fadeOut;
    await _ctrl.reverse();
    widget.state.remove();
  }

  @override
  void dispose() {
    _dismissTimer.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 96,
      left: 12,
      right: 12,
      child: Semantics(
        liveRegion: true,
        label: '${widget.state.message}, ${widget.state.actionLabel}',
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppColors.dialogRadius),
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppColors.dialogRadius),
                border: Border.all(color: colorScheme.outline, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.state.message,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        widget.state.onAction();
                        _dismiss();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        minimumSize: const Size(72, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppColors.dialogActionRadius,
                          ),
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      child: Text(
                        widget.state.actionLabel,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
