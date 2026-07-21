import 'package:flutter/material.dart';
import 'breakpoints.dart';

extension WindowSizeExtension on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width < AppBreakpoints.compact) return ScreenSize.compact;
    if (width < AppBreakpoints.medium) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isMedium => screenSize == ScreenSize.medium;
  bool get isExpanded => screenSize == ScreenSize.expanded;
}
