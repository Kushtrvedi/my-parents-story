import 'package:flutter/material.dart';
import 'window_size.dart';
import 'breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = context.screenSize;
        if (size == ScreenSize.expanded && expanded != null) {
          return expanded!(context);
        }
        if ((size == ScreenSize.medium || size == ScreenSize.expanded) &&
            medium != null) {
          return medium!(context);
        }
        return compact(context);
      },
    );
  }
}
