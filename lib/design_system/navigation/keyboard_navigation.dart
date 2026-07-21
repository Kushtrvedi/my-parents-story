import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin KeyboardNavigation<T extends StatefulWidget> on State<T> {
  FocusNode? _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _keyboardFocusNode?.dispose();
    super.dispose();
  }

  Widget buildKeyboardListener({
    required Widget child,
    VoidCallback? onEscape,
    VoidCallback? onEnter,
    Map<LogicalKeyboardKey, VoidCallback>? customHandlers,
  }) {
    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape && onEscape != null) {
            onEscape();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
            onEnter();
            return KeyEventResult.handled;
          }
          if (customHandlers != null && customHandlers.containsKey(event.logicalKey)) {
            customHandlers[event.logicalKey]!();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
