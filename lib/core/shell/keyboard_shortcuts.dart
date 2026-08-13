import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class SwitchTabIntent extends Intent {
  const SwitchTabIntent(this.index);
  final int index;
}

final tabShortcuts = <LogicalKeySet, Intent>{
  LogicalKeySet(LogicalKeyboardKey.digit1): const SwitchTabIntent(0),
  LogicalKeySet(LogicalKeyboardKey.digit2): const SwitchTabIntent(1),
  LogicalKeySet(LogicalKeyboardKey.digit3): const SwitchTabIntent(2),
  LogicalKeySet(LogicalKeyboardKey.digit4): const SwitchTabIntent(3),
  LogicalKeySet(LogicalKeyboardKey.digit5): const SwitchTabIntent(4),
  LogicalKeySet(LogicalKeyboardKey.f1): const SwitchTabIntent(0),
  LogicalKeySet(LogicalKeyboardKey.f2): const SwitchTabIntent(1),
  LogicalKeySet(LogicalKeyboardKey.f3): const SwitchTabIntent(2),
  LogicalKeySet(LogicalKeyboardKey.f4): const SwitchTabIntent(3),
  LogicalKeySet(LogicalKeyboardKey.f5): const SwitchTabIntent(4),
};
