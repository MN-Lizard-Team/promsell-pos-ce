import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Captures USB/BT keyboard-wedge barcode scanners on the Sale screen.
///
/// Guns type characters rapidly then send Enter (or Tab). We buffer alnum
/// chars and emit when a terminator arrives. Slow typing (human) is ignored
/// via inter-key timeout. Focus inside a text field disables capture.
class BarcodeWedgeListener extends StatefulWidget {
  const BarcodeWedgeListener({
    super.key,
    required this.child,
    required this.onBarcode,
    this.enabled = true,
    this.interKeyTimeout = const Duration(milliseconds: 80),
    this.minLength = 4,
  });

  final Widget child;
  final ValueChanged<String> onBarcode;
  final bool enabled;
  final Duration interKeyTimeout;
  final int minLength;

  @override
  State<BarcodeWedgeListener> createState() => _BarcodeWedgeListenerState();
}

class _BarcodeWedgeListenerState extends State<BarcodeWedgeListener> {
  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeyAt;
  final FocusNode _focusNode = FocusNode(debugLabel: 'barcode-wedge');

  static final _alnum = RegExp(r'^[a-zA-Z0-9]$');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _textFieldFocused {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return false;
    // Editable text fields set context that includes EditableText.
    final ctx = primary.context;
    if (ctx == null) return false;
    return ctx.findAncestorWidgetOfExactType<EditableText>() != null ||
        ctx.widget is EditableText;
  }

  void _resetBuffer() {
    _buffer.clear();
    _lastKeyAt = null;
  }

  void _flushIfReady() {
    final code = _buffer.toString().trim().toUpperCase();
    _resetBuffer();
    if (code.length < widget.minLength) return;
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(code)) return;
    widget.onBarcode(code);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_textFieldFocused) {
      _resetBuffer();
      return KeyEventResult.ignored;
    }

    final now = DateTime.now();
    if (_lastKeyAt != null &&
        now.difference(_lastKeyAt!) > widget.interKeyTimeout &&
        _buffer.isNotEmpty) {
      // Gap too large → human typing or stalled buffer; drop.
      _resetBuffer();
    }
    _lastKeyAt = now;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.tab) {
      if (_buffer.isNotEmpty) {
        _flushIfReady();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Character from key event (letters/digits).
    final ch = event.character;
    if (ch != null && ch.isNotEmpty && _alnum.hasMatch(ch)) {
      _buffer.write(ch);
      return KeyEventResult.handled;
    }

    // Some platforms omit character; map digit keys.
    final label = key.keyLabel;
    if (label.length == 1 && _alnum.hasMatch(label)) {
      _buffer.write(label);
      return KeyEventResult.handled;
    }

    // Non-barcode key mid-buffer → abort.
    if (_buffer.isNotEmpty) {
      _resetBuffer();
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.enabled,
      canRequestFocus: widget.enabled,
      onKeyEvent: _onKey,
      child: widget.child,
    );
  }
}
