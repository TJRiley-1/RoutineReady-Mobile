import 'package:flutter/material.dart';
import '../../models/theme_config.dart';
import '../../utils/theme_utils.dart';
import '../../utils/time_utils.dart';

class ProgressLine extends StatelessWidget {
  final int taskDuration;
  final double elapsed;
  final bool isPast;
  final bool isActive;
  final double lineWidth;
  final ThemeConfig theme;

  const ProgressLine({
    super.key,
    required this.taskDuration,
    required this.elapsed,
    required this.isPast,
    required this.isActive,
    required this.lineWidth,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        getProgressPercentage(isPast, isActive, elapsed, taskDuration) / 100;

    return SizedBox(
      width: lineWidth,
      height: 24,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background track
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: parseHexColor(theme.progressBgColor),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          // Filled portion
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 12,
            width: lineWidth * progress,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  parseHexColor(
                      theme.progressLineColors['from'] ?? '#5EEAD4'),
                  parseHexColor(
                      theme.progressLineColors['to'] ?? '#0D9488'),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          // Dot indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            left: (lineWidth * progress - 8).clamp(0, lineWidth - 16),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: parseHexColor(
                    isPast
                        ? theme.tickPastColor
                        : isActive
                            ? theme.tickCurrentColor
                            : theme.tickFutureColor,
                  ),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
