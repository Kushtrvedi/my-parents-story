import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../colors.dart';

class VoiceWaveformWidget extends StatefulWidget {
  final bool isRecording;
  final double height;

  const VoiceWaveformWidget({
    super.key,
    required this.isRecording,
    this.height = 48,
  });

  @override
  State<VoiceWaveformWidget> createState() => _VoiceWaveformWidgetState();
}

class _VoiceWaveformWidgetState extends State<VoiceWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isRecording) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecording && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(16, (index) {
              double animValue = 0.3;
              if (widget.isRecording) {
                final phase = (index * 0.4) + (_controller.value * 2 * math.pi);
                animValue = 0.2 + (0.8 * (0.5 + 0.5 * math.sin(phase)));
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 4,
                height: widget.height * animValue,
                decoration: BoxDecoration(
                  color:
                      widget.isRecording ? AppColors.accent : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
