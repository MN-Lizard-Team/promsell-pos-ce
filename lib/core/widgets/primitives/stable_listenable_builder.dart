import 'package:flutter/widgets.dart';

/// Like [ListenableBuilder], but keeps a stable [Listenable.merge] identity
/// while the underlying listenables are the same instances.
///
/// Avoids `TextEditingController was used after being disposed` races that
/// happen when `Listenable.merge([...])` is recreated every parent rebuild
/// (AnimatedWidget re-subscribes in [State.didUpdateWidget]).
class StableListenableBuilder extends StatefulWidget {
  const StableListenableBuilder({
    super.key,
    required this.listenables,
    required this.builder,
    this.child,
  });

  final List<Listenable> listenables;
  final TransitionBuilder builder;
  final Widget? child;

  @override
  State<StableListenableBuilder> createState() =>
      _StableListenableBuilderState();
}

class _StableListenableBuilderState extends State<StableListenableBuilder> {
  late Listenable _merged;

  @override
  void initState() {
    super.initState();
    _merged = _merge(widget.listenables);
  }

  @override
  void didUpdateWidget(covariant StableListenableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameInstances(oldWidget.listenables, widget.listenables)) {
      _merged = _merge(widget.listenables);
    }
  }

  static Listenable _merge(List<Listenable> listenables) {
    if (listenables.isEmpty) return const _EmptyListenable();
    if (listenables.length == 1) return listenables.first;
    return Listenable.merge(listenables);
  }

  static bool _sameInstances(List<Listenable> a, List<Listenable> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _merged,
      builder: widget.builder,
      child: widget.child,
    );
  }
}

class _EmptyListenable extends Listenable {
  const _EmptyListenable();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
