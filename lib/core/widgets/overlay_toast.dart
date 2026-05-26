import 'package:flutter/material.dart';

abstract final class OverlayToast {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    if (!context.mounted) return;
    final overlay = Overlay.of(context);
    final entry = _OverlayToastEntry(message: message, duration: duration);
    overlay.insert(entry.overlayEntry);
  }
}

class _OverlayToastEntry {
  _OverlayToastEntry({required this.message, required this.duration}) {
    overlayEntry = OverlayEntry(builder: (_) => _ToastWidget(state: this));
  }

  final String message;
  final Duration duration;
  late final OverlayEntry overlayEntry;

  void remove() {
    if (overlayEntry.mounted) overlayEntry.remove();
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({required this.state});

  final _OverlayToastEntry state;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  static const _fadeIn = Duration(milliseconds: 150);
  static const _fadeOut = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _fadeIn);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(widget.state.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    _ctrl.duration = _fadeOut;
    await _ctrl.reverse();
    widget.state.remove();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 16,
      left: 0,
      right: 0,
      child: IgnorePointer(
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
                  color: colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get message => widget.state.message;
}
