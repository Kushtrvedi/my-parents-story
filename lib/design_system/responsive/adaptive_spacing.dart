import 'package:flutter/material.dart';
import 'window_size.dart';
import '../spacing.dart';

class AdaptiveSpacing {
  static double horizontalPadding(BuildContext context) {
    if (context.isExpanded) return AppSpacing.xxl;
    if (context.isMedium) return AppSpacing.xl;
    return AppSpacing.l;
  }
}
