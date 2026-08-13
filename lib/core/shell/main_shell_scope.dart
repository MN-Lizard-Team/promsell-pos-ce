import 'package:flutter/material.dart';

/// Lets shell children switch bottom-nav / rail tabs without pushing routes.
///
/// Provided by `MainShell` in `lib/core/shell/main_shell.dart`.
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.goToTab,
    required super.child,
  });

  /// Switch to shell tab index (0=Home … 4=Settings).
  final void Function(int index) goToTab;

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  static MainShellScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'MainShellScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      goToTab != oldWidget.goToTab;
}
