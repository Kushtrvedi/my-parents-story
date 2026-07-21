import 'package:flutter/material.dart';

class AdaptiveCenteredBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AdaptiveCenteredBox({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class TwoColumnLayout extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;
  final int leftFlex;
  final int rightFlex;
  final double spacing;

  const TwoColumnLayout({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.spacing = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: leftChild),
        SizedBox(width: spacing),
        Expanded(flex: rightFlex, child: rightChild),
      ],
    );
  }
}
