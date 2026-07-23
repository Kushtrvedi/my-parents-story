import 'dart:math';
import 'package:flutter/material.dart';

class PageTurnRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  PageTurnRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final angle = (1.0 - animation.value) * (pi / 2);
                final opacity = (animation.value * 2).clamp(0.0, 1.0);

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015) 
                    ..rotateY(-angle), 
                  alignment: Alignment.centerLeft, 
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}
